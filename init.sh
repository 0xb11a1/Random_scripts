#!/bin/bash

# -----------
# |  Usage: |
# -----------
# bash -c "$(wget -O- https://raw.githubusercontent.com/0xb11a1/Random_scripts/main/init.sh)"
# after installation - open tmux and press Prefix+I to install the theme

cd ~ 
# ---------------------- install essential packages
sudo apt update && sudo apt install tmux zsh vim curl git xclip \
python3-pip python3-dev git libssl-dev libffi-dev build-essential unzip -y

# ----------------------  dracula tmux theme

cat > .tmux.conf <<EOF
# ------ added by me
set -g prefix C-Space
bind C-Space send-prefix
# Switch panes 
# Usage: 'ALT+arrow keys' (without prefix key)
# from https://gist.github.com/spicycode
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Switch windows 
# usage: 'SHIFT+arrow' (without prefix key)
bind -n S-Left  previous-window
bind -n S-Right next-window

set -g mouse on
set -g history-limit 10000

# Set new panes to open in current directory
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"


# ------ TPM

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'dracula/tmux'

# conf for darcula/tmux 
set -g @dracula-show-location false
set -g @dracula-show-time false
set -g @dracula-show-weather false
set -g @dracula-show-network false


# autoinstall 
if "test ! -d ~/.tmux/plugins/tpm" \
    "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF

# ---------------------- oh my zsh
sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 

# adding 'agkozak' theme
[[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes ]] && mkdir ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes
git clone https://github.com/agkozak/agkozak-zsh-prompt ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/agkozak
ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/agkozak/agkozak-zsh-prompt.plugin.zsh ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/agkozak.zsh-theme
sed -E  's/ZSH_THEME="(.+)"/ZSH_THEME="agkozak"/g' -i .zshrc 

# install extentions
plugins_name="zsh-autosuggestions zsh-syntax-highlighting git"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -E  "s/plugins=\((.+)\)/plugins=\(${plugins_name}\)/g" -i .zshrc

# ---------------------- .zshrc dotfile
echo "
alias xclip='xclip -selection clipboard'
AGKOZAK_COLORS_USER_HOST=green
AGKOZAK_PROMPT_CHAR=( ∑ ∑# : )

" >> ~/.zshrc

# change shell to zsh
echo '[+] changing default shell to zsh'
chsh -s `which zsh`


# ---------------------- install Caskaydia Cove Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip -O /tmp/CascadiaCode.zip
mkdir -p ~/.local/share/fonts ;  unzip /tmp/CascadiaCode.zip Caskaydia\ Cove\ Nerd\ Font\ Complete.ttf -d ~/.local/share/fonts

# ---------------------- install gef in gdb 
wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
echo source ~/.gdbinit-gef.py >> ~/.gdbinit