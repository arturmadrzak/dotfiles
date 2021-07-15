#!/usr/bin/env sh

set -eu

APT_PACKAGES=" \
    editorconfig \
    python3-dev \
    shellcheck \
    tmux \
    vim \
    vim-gtk3 \
    "

install_apt()
{
    for _pkg in ${APT_PACKAGES}; do
        if ! dpkg -s "${_pkg}" >/dev/null 2>&1; then
            _not_installed="${_not_installed:-} ${_pkg}"
        fi
    done
    if [ -n "${_not_installed:-}" ]; then
        sudo /bin/sh -c "apt update && apt install --yes ${_not_installed}"
    fi
}

install_vim()
{
    _vimdir="${HOME}/.vim"
    if [ -e "${_vimdir}" ]; then
        echo "Warning: Backing up '${_vimdir}' to '${_vimdir}.bak'"
        mv -T "${_vimdir}" "${_vimdir}.bak"
    fi
    ln -sT "${PWD}/vim" "${_vimdir}"
}

install_tmux()
{
    _tmuxconf="${HOME}/.tmux.conf"
    if [ -e "${_tmuxconf}" ]; then
        echo "Warning: Backing up '${_tmuxconf}' to '${_tmuxconf}.bak'"
        mv "${_tmuxconf}" "${_tmuxconf}.bak"
    fi
    ln -sT "${PWD}/tmux.conf" "${_tmuxconf}"
}

install_fuzzy_completer()
{
    ./fzf/install --all > /dev/null
}

install_ycm()
{
    ./vim/pack/general/start/youcompleteme/install.py --clangd-completer
}

install_editorconfig()
{
    _target="${HOME}/.editorconfig"
    if [ -e "${_target}" ]; then
        echo "Warning: Backing up '${_target}' to '${_target}.bak'"
        mv "${_target}" "${_target}.bak"
    fi
    ln -sT "${PWD}/editorconfig" "${_target}"
}

main()
{
    install_apt
    install_vim
    install_tmux
    install_fuzzy_completer
    install_ycm
    install_editorconfig
}

main "${@}"
