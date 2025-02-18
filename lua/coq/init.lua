local config = require('coq.config')
local util = require('coq.util')

local v = vim
local api = v.api
local fn = v.fn

local M = {}

local cwd = util.get_script_path() or util.seek_rtp()

local is_win = api.nvim_call_function('has', {'win32'}) == 1

local linesep = '\n'
local POLLING_RATE = 10
local job_id = nil
local err_exit = false

local on_exit = function(_, code)
    local msg = ' | COQ EXITED - ' .. code
    if not (code == 0 or code == 143) then
        err_exit = true
        api.nvim_err_writeln(msg)
    else
        err_exit = false
    end
    job_id = nil
end

local on_stdout =
  function(_, msg) api.nvim_out_write(table.concat(msg, linesep)) end

local on_stderr =
  function(_, msg) api.nvim_err_write(table.concat(msg, linesep)) end

local go, _py3 = pcall(api.nvim_get_var, 'python3_host_prog')
local py3 = go and _py3 or (is_win and 'python' or 'python3')

local main = function()
    local v_py = cwd .. (is_win and [[/.vars/runtime/Scripts/python.exe]] or
                   '/.vars/runtime/bin/python3')
    local win_proxy = cwd .. [[/win.bat]]

    if is_win then
        if fn.filereadable(v_py) == 1 then
            return {v_py}
        else
            return {win_proxy, py3}
        end
    else
        if fn.filereadable(v_py) == 1 then
            return {v_py}
        else
            return {py3}
        end
    end
end

local start = function(deps, ...)
    local args = v.tbl_flatten {deps and py3 or main(), {'-m', 'coq'}, {...}}

    local params = {
        cwd = cwd,
        on_exit = on_exit,
        on_stdout = on_stdout,
        on_stderr = on_stderr,
    }
    job_id = fn.jobstart(args, params)
    return job_id
end

M.COQdeps = function() start(true, 'deps') end

local set_coq_call = function(cmd)
    M[cmd] = function(...)
        local args = {...}

        if not job_id then
            local server = api.nvim_call_function('serverstart', {})
            job_id = start(false, 'run', '--socket', server)
        end

        if not err_exit and _G[cmd] then
            _G[cmd](args)
        else
            v.defer_fn(function()
                if err_exit then
                    return
                else
                    M[cmd](unpack(args))
                end
            end, POLLING_RATE)
        end
    end
end

api.nvim_command [[command! -nargs=0 COQdeps lua require("coq").COQdeps()]]

set_coq_call('COQnow')
api.nvim_command [[command! -complete=customlist,coq#complete_now -nargs=* COQnow lua require("coq").COQnow(<f-args>)]]

set_coq_call('COQstats')
api.nvim_command [[command! -nargs=* COQstats lua require("coq").COQstats(<f-args>)]]

set_coq_call('COQhelp')
api.nvim_command [[command! -complete=customlist,coq#complete_help  -nargs=* COQhelp lua require("coq").COQhelp(<f-args>)]]

M.lsp_ensure_capabilities = function(cfg)
    local spec1 = {capabilities = v.lsp.protocol.make_client_capabilities()}
    local spec2 = {
        capabilities = {
            textDocument = {
                completion = {completionItem = {snippetSupport = true}},
            },
        },
    }
    local maps = (cfg or {}).capabilities and {spec2} or {spec1, spec2}
    local new = v.tbl_deep_extend('force', cfg or v.empty_dict(), unpack(maps))
    return new
end

M.setup = function(opts)
    config = util.merge_tables(config, opts)

    -- @TODO adding coq_setting for compatibility reasons but
    -- it is better to keep them locally and configure
    v.g.coq_settings = config

    if v.g.python3_host_prog ~= nil then
        v.g.python3_host_prog = config.python3_host_prog
    end

    if config.auto_start then M.COQnow() end
end

return M
