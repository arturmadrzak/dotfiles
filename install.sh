#!/usr/bin/env bash

set -eu

VIM_ADDONS_EXTRA=${HOME}/.local/share/vim/addons
TMUX_PLUGINS=${HOME}/.tmux/plugins

# vim-gtk3 allow X11 clipboard integration
APT_PACKAGES=" \
    autoimport \
    black \
    editorconfig \
    flake8 \
    isort \
    python3-dev \
    shellcheck \
    shfmt \
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

vim_enable()
{
    name=${1?Missing pack name}
    if ! vim-addons -q status "${name}" | grep -q installed; then
        echo "[ENABLE] ${name}"
        vim-addons install "${name}"
    fi
}

git_clone()
{
    root=${1:?Missing root directory}
    url=${2:?Missing repo url}
    name=${url##*/}
    name=${name%.git}

    echo "[CLONE] ${name}"

    if [ -e "${root}/${name}" ]; then
        echo "'${name}' is already checked out in '${root}'"
        printf "(s)kip, (r)emove, (u)pdate, (a)bort: "
        read -n 1 -r answer
        echo
        case "${answer}" in
            s)
                return ;;
            r)
                rm -rf "${root:-}/${name:-}" ;;
            u)
                git -C "${root:-}/${name:-}" pull
                return ;;
            *)
                echo "Aborted..."
                exit 1 ;;
        esac
    fi
    git -C "${root:-}" clone -q "${url:-}"
}

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
    install -d "${HOME}/.vim"
    for rc in vim/*; do
        echo "[INSTALL] ${rc}"
        install -m 644 -t "${HOME}/.vim" "${rc}"
    done

    install -d "${VIM_ADDONS_EXTRA}"
    git_clone "${VIM_ADDONS_EXTRA}" https://github.com/preservim/nerdtree.git
    git_clone "${VIM_ADDONS_EXTRA}" https://github.com/Xuyuanp/nerdtree-git-plugin.git
    git_clone "${VIM_ADDONS_EXTRA}" https://github.com/jistr/vim-nerdtree-tabs.git
    git_clone "${VIM_ADDONS_EXTRA}" https://github.com/rbgrouleff/bclose.vim.git
    git_clone "${VIM_ADDONS_EXTRA}" https://github.com/github/copilot.vim.git

    vim_enable editorconfig
}

install_tmux()
{
    echo "[INSTALL] tmux plugins"
    mkdir -p "${TMUX_PLUGINS}"
    git_clone "${TMUX_PLUGINS}" https://github.com/tmux-plugins/tpm.git
    echo "[INSTALL] tmux.conf"
    install -m 644 -T tmux.conf "${HOME}/.tmux.conf"
}

install_fuzzy_completer()
{
    git_clone "${HOME}/.local/share" https://github.com/junegunn/fzf.git
    "${HOME}/.local/share/fzf/install" --all > /dev/null
}

install_editorconfig()
{
    install -m 644 -T editorconfig "${HOME}/.editorconfig"
}

main()
{
    install_apt
    install_tmux
    install_editorconfig
    install_vim
    install_fuzzy_completer
}

main "${@}"
