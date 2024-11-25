#!/usr/bin/env sh

set -eu

DOTFILES_PATH="${0%/*}"

# vim-gtk3 allow X11 clipboard integration
APT_PACKAGES=" \
    autoimport \
    editorconfig \
    python3-dev \
    shellcheck \
    tmux \
    vim-airline \
    vim-ale \
    vim-common \
    vim-editorconfig \
    vim-gitgutter \
    vim-gtk3 \
    vim-nox \
    vim-solarized \
    vim-youcompleteme \
    yamllint
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
    ln -sT "${DOTFILES_PATH}/vim" "${_vimdir}"
}

install_tmux()
{
    _tmuxconf="${HOME}/.tmux.conf"
    if [ -e "${_tmuxconf}" ]; then
        echo "Warning: Backing up '${_tmuxconf}' to '${_tmuxconf}.bak'"
        mv "${_tmuxconf}" "${_tmuxconf}.bak"
    fi
    ln -sT "${DOTFILES_PATH}/tmux.conf" "${_tmuxconf}"
}

install_fuzzy_completer()
{
    "${DOTFILES_PATH}/fzf/install" --all > /dev/null
}

install_editorconfig()
{
    _target="${HOME}/.editorconfig"
    if [ -e "${_target}" ]; then
        echo "Warning: Backing up '${_target}' to '${_target}.bak'"
        mv "${_target}" "${_target}.bak"
    fi
    ln -sT "${DOTFILES_PATH}/editorconfig" "${_target}"
}

main()
{
    install_apt
    install_vim
    install_tmux
    install_fuzzy_completer
    install_editorconfig
}

main "${@}"
