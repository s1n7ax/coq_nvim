# Fuzzy Completion

The **BEST** async completion framework for Neovim

## VScode Style Fuzzy Search

Async completion on every keystroke.

Fuzzy search all the results.

![preview.png](https://raw.githubusercontent.com/ms-jpq/fast-comp/nvim/preview/screenshot.png)

## Advanced Scheduler

- Concurrent! multi source completion

- Streaming incremental sources

- Never blocks

- Cancel culture (fetch first, cancel later)

- Hackable (EASY extension protocol, dynamic json config)

## Install

Requires pyvim (as all python plugins do)

```sh
pip3 install pynvim
```

Install the usual way, ie. [VimPlug](https://github.com/junegunn/vim-plug), [Vundle](https://github.com/VundleVim/Vundle.vim), etc

```VimL
Plug 'ms-jpq/fuzzy-completion', {'branch': 'nvim', 'do': ':UpdateRemotePlugins'}
```

## Documentation

### Builtin Sources

| name                                                                                       | source                                                                  |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| [LSP](https://github.com/ms-jpq/fuzzy-completion/blob/nvim/clients/lsp.py)                 | Fetches results from Neovim LSP client                                  |
| [Tree Sitter](https://github.com/ms-jpq/fuzzy-completion/blob/nvim/clients/tree_sitter.py) | Fetches results from syntax tree (still waiting on next Neovim release) |
| [Buffers](https://github.com/ms-jpq/fuzzy-completion/blob/nvim/clients/buffers.py)         | Fetches results from open buffers                                       |
| [Paths](https://github.com/ms-jpq/fuzzy-completion/blob/nvim/clients/paths.py)             | Fetches results from file paths                                         |

### Plugin Sources

| name                                                          | source                                                            |
| ------------------------------------------------------------- | ----------------------------------------------------------------- |
| [TabNine](https://github.com/ms-jpq/fuzzy-completion-clients) | Fetches results from [TabNine](https://www.tabnine.com/) ML model |

### Configuration

Check out the [basic config](https://github.com/ms-jpq/fuzzy-completion/blob/nvim/config/config.json) before you proceed.
