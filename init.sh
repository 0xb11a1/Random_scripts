#!/bin/bash

# -----------
# |  Usage: |
# -----------
# bash -c "$(wget -O- https://raw.githubusercontent.com/0xb11a1/Random_scripts/main/init.sh)"
# after installation - open tmux and press Prefix+I to install the theme

cd ~ 
# ---------------------- install essential packages
sudo NEEDRESTART_MODE=a apt update && sudo apt install tmux zsh vim curl git xclip gdb wget htop net-tools  \
python3-pip python3-dev git libssl-dev libffi-dev build-essential unzip python3-venv fzf -y

sudo NEEDRESTART_MODE=a apt install golang-go cargo -y 
# sudo NEEDRESTART_MODE=a apt install pipx neovim -y
pipx ensurepath
sudo pipx ensurepath --global


# ---------------------- install startship zsh
sudo sh -c "$(wget -qO- https://starship.rs/install.sh)" "" -y

# ---------------------- install docker
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        echo "[+] Detected Ubuntu system."
        if ! command -v snap &> /dev/null; then
            echo "[*] Snap not found. Installing snapd..."
            sudo NEEDRESTART_MODE=a apt install snapd -y
        fi
        sudo snap install docker
        sudo snap install nvim --classic

    else
        sudo NEEDRESTART_MODE=a apt install docker docker-compose -y
    fi
else
    echo "[-] Cannot determine operating system."
fi


sudo systemctl enable docker --now
sudo usermod -aG docker $USER
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
set -g @plugin "arcticicestudio/nord-tmux"


# autoinstall 
if "test ! -d ~/.tmux/plugins/tpm" \
    "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

# set copy mode to Vi and enable copy on select
setw -g mode-keys vi
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -selection c"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"

# ---------------------- log tmux panes
#log_location=$HOME/.tmux/logs
#test -d "\$log_location" || mkdir "\$log_location"
#tmux pipe-pane "cat >> \$log_location/tmux_session_#S_#I_#P_$(date +%Y%m%d%H%M%S).log" 2> /dev/null

bind t {
copy-mode
  send -X clear-selection
  send -X cursor-up
  send -X start-of-line
  send -X start-of-line
  send -X cursor-up
  send -X start-of-line
  send -X start-of-line

  if -F "#{m:*♜,#{copy_cursor_line}}" {
    send -X search-forward-text "♜"
    send -X stop-selection
    send -X -N 2 cursor-right
    send -X begin-selection
    send -X end-of-line
    send -X end-of-line
    if "#{m:*♜?*,#{copy_cursor_line}}" {
      send -X cursor-left
    }
  } {
    send -X end-of-line
    send -X end-of-line
    send -X begin-selection
    send -X search-backward-text "♜"
    send -X cursor-up
    send -X end-of-line
    send -X end-of-line
    send -X cursor-right
    send -X stop-selection
  }


}


bind o {
copy-mode
  send -X clear-selection
  send -X cursor-up
  send -X start-of-line
  send -X start-of-line
  send -X cursor-up
  send -X start-of-line
  send -X start-of-line

  if -F "#{m:*♜,#{copy_cursor_line}}" {
    send -X search-forward-text "♜"
    send -X stop-selection
    send -X -N 2 cursor-right
    send -X begin-selection
    send -X end-of-line
    send -X end-of-line
    if "#{m:*♜?*,#{copy_cursor_line}}" {
      send -X cursor-left
    }
  } {
    send -X end-of-line
    send -X cursor-left
    send -X begin-selection
    send -X search-backward-text "♜"
    #send -X cursor-up
    send -X end-of-line
    send -X end-of-line
    send -X cursor-right
    send -X stop-selection
  }


}

EOF

# ---------------------- oh my zsh
sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 

# # adding 'agkozak' theme
# [[ ! -d $ZSH_CUSTOM/themes ]] && mkdir $ZSH_CUSTOM/themes
# git clone https://github.com/agkozak/agkozak-zsh-prompt $ZSH_CUSTOM/themes/agkozak
# ln -s $ZSH_CUSTOM/themes/agkozak/agkozak-zsh-prompt.plugin.zsh $ZSH_CUSTOM/themes/agkozak.zsh-theme
# sed -E  's/ZSH_THEME="(.+)"/ZSH_THEME="agkozak"/g' -i .zshrc 

# install extentions
plugins_name="zsh-autosuggestions zsh-syntax-highlighting git zsh-fzf-history-search"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search
sed -E  "s/plugins=\((.+)\)/plugins=\(${plugins_name}\)/g" -i .zshrc


# ---------------------- nvim 

git clone https://github.com/NvChad/starter ~/.config/nvim

# ---------------------- .zshrc dotfile
cat > ~/.zshrc <<EOF

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(zsh-autosuggestions zsh-syntax-highlighting git zsh-fzf-history-search)

source \$ZSH/oh-my-zsh.sh

function volatility() {
  docker run --rm --user=$(id -u):$(id -g) -v "$(pwd)":/dumps:ro,Z -ti phocean/volatility $@
}

JAVA_HOME="/usr/bin/"
export VISUAL="vim"

alias xclip="xclip -selection clipboard"
alias clear='clear -x'

export PATH=$PATH:~/.local/bin:/usr/local/go/bin:~/go/bin:~/.cargo/bin:~/genymotion
export TERM=xterm-256color
export LANG=C.UTF-8

eval "\$(starship init zsh)"

alias vim=nvim

EOF

# ---------------------- starship config
mkdir -p ~/.config && touch ~/.config/starship.toml

cat > ~/.config/starship.toml <<EOF
add_newline = false

[username]
style_user = "green bold"
style_root = "red bold"
format = "[\$user](\$style) "

[character] 
success_symbol = '[♜](bold green)'
error_symbol	 = '[♜](bold red)'

EOF

# change shell to zsh
echo '[+] changing default shell to zsh'
sudo chsh -s `which zsh` $USER


# ---------------------- install Caskaydia Cove Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip -O /tmp/CascadiaCode.zip
mkdir -p ~/.local/share/fonts ;  unzip /tmp/CascadiaCode.zip Caskaydia\ Cove\ Nerd\ Font\ Complete.ttf -d ~/.local/share/fonts

# ---------------------- install gef in gdb 
wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
echo source ~/.gdbinit-gef.py >> ~/.gdbinit

