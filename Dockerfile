FROM ubuntu:latest 

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV XDG_CONFIG_HOME $HOME/.config
ENV XDG_DATA_HOME $HOME/.local/share

# Locales
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8

WORKDIR /$HOME/myconfig-file

COPY ./.config .config
COPY ./scripts scripts

RUN chmod +x ./scripts/ubuntu/0_install_fish_tmux_vim.sh
RUN chmod +x ./scripts/ubuntu/1_symbol_config_fish_tmux_vim.sh
RUN chmod +x ./scripts/ubuntu/2_install_font_nvm_cargo.sh
RUN chmod +x ./scripts/ubuntu/3_1_install_alacritty_terminal.sh
RUN chmod +x ./scripts/ubuntu/4_install_android_sdk.sh
RUN chmod +x ./scripts/ubuntu/5_install_flutter.sh

# set workdir for install sh
WORKDIR /$HOME/myconfig-file/scripts/ubuntu

RUN ./0_install_fish_tmux_vim.sh
RUN ./1_symbol_config_fish_tmux_vim.sh
RUN fish ./2_install_font_nvm_cargo.sh
RUN fish ./4_install_android_sdk.sh
RUN fish ./5_install_flutter.sh

# RUN ./3_1_install_alacritty_terminal.sh

# start at home
WORKDIR /$HOME
# auto forward to fish
ENTRYPOINT [ "bash" ]
