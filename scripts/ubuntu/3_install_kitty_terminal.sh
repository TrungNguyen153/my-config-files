


sudo curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

sudo mkdir -p $HOME/.local/bin
# Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in
# your PATH)
sudo ln -s -f $HOME/.local/kitty.app/bin/kitty $HOME/.local/bin/

# Place the kitty.desktop file somewhere it can be found by the OS
sudo cp $HOME/.local/kitty.app/share/applications/kitty.desktop $HOME/.local/share/applications/

# Update the path to the kitty icon in the kitty.desktop file
sudo sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" $HOME/.local/share/applications/kitty.desktop

