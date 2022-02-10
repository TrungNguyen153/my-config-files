#!/usr/bin/fish

echo 'Load Tmux tpm...'
# load plugin
tmux start-server && \
    tmux new-session -d && \
    sleep 1 && \
    $HOME/.tmux/plugins/tpm/tpm && \
    $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh && \
    tmux kill-server

echo 'Remove nvim/plugin complied...'
rm -rf $HOME/.config/nvim/plugin

echo 'Load Nvim Plugin...'

nvim --headless -c 'autocmd User PackerComplete quitall' #-c 'PackerSync' #dont need because bootstrap
# auto update nvim-treesitter after compile
nvim --headless -c 'TSInstallSync all' -c 'quitall'

echo 'Done all!'
