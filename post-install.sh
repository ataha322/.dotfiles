# general system setup
mkdir ~/.local/bin

sudo kernelstub -d "quiet systemd.show_status=false splash"
sudo kernelstub -a "systemd.show_status=true"

hostnamectl set-hostname blade13
sudo system76-power graphics hybrid

sudo apt update && sudo apt upgrade -y
sudo apt autopurge

sudo apt install -y vlc gnome-tweaks xclip python3-pip gh



# JetBrainsMono Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
sudo mkdir /usr/share/fonts/jetbrains
sudo unzip JetBrainsMono.zip -d /usr/share/fonts/jetbrains
fc-cache -fv
rm JetBrainsMono.zip

# kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ~/.local/bin/kitty 50

# neovim 
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -xzvf nvim-linux64.tar.gz
sudo cp -r nvim-linux64/bin/* /usr/local/bin/
sudo cp -r nvim-linux64/lib/* /usr/local/lib/
sudo cp -r nvim-linux64/man/* /usr/local/man/
sudo cp -r nvim-linux64/share/* /usr/local/share/
rm -r nvim-linux64
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 50

# openrazer
sudo add-apt-repository ppa:openrazer/stable
sudo apt update
sudo apt install -y openrazer-meta
sudo gpasswd -a $USER plugdev
pip install razer-cli
