set fish_greeting ""

set -gx TERM xterm-256color


# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git


command -qv nvim && alias vim nvim

# ide for open ide mode
#alias ide "sh ~/tmux-ide.sh"
alias ide='tmux split-window -v -p 30; tmux split-window -h -p 66; tmux split-window -h -p 50'
alias mux='pgrep -vx tmux > /dev/null && \
		tmux new -d -s delete-me && \
		tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh && \
		tmux kill-session -t delete-me && \
		tmux attach || tmux attach'


set -gx EDITOR nvim
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH

# Default Node Version Manager plugin
set --universal nvm_default_version v16

# Rust plugin installed by cargo
set PATH $HOME/.cargo/bin $PATH

# Dart & Flutter
set PATH $HOME/flutter/bin $PATH
set PATH $HOME/flutter/.pub-cache/bin $PATH
set PATH $HOME/flutter/bin/cache/dart-sdk/bin $PATH

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

switch (uname)
  case Darwin
    source (dirname (status --current-filename))/config-osx.fish
  case Linux
    source (dirname (status --current-filename))/config-linux.fish
  case '*'
    source (dirname (status --current-filename))/config-windows.fish
end
