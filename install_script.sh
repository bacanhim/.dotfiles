sudo dnf update
sudo dnf copr enable bzaidan/Hyprland
sudo dnf install zsh zsh-syntax-highlighting zsh-autosuggestions @virtualization stow hyprland swaybg alacritty wofi slurp jetbrains-mono-fonts pavucontrol
cd ~/.dotfiles/
stow --target="$HOME" --no-folding .
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.spotify.Client
flatpak install flathub com.teamspeak.TeamSpeak
flatpak install flathub com.visualstudio.code