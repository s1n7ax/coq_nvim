FROM ubuntu:focal

ENV TERM=xterm-256color
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes -- software-properties-common && \
    add-apt-repository ppa:neovim-ppa/unstable && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes -- \
    python3-venv git neovim universal-ctags tmux && \
    rm -rf /var/lib/apt/lists/*


ADD https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim /root/.config/nvim/autoload/plug.vim
COPY ./docker/fs /
WORKDIR /root/.config/nvim/plugged
RUN git clone --depth=1 -- https://github.com/ms-jpq/chadtree.git && \
    git clone --depth=1 -- https://github.com/ms-jpq/coq.artifacts.git
RUN cd /root/.config/nvim/plugged/chadtree || exit 1 && \
    python3 -m chadtree deps
COPY ./ /root/.config/nvim/plugged/coq_nvim
RUN cd /root/.config/nvim/plugged/coq_nvim || exit 1 && \
    python3 -m coq deps


# ENV COQ_DEBUG=1 \
#     COQ_DEBUG_DB=1
