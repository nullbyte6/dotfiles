export MAUVE="\e[38;2;198;160;246m"
export GREEN="\e[38;2;166;218;149m"
export BLUE="\e[38;2;138;173;244m"

export PS1="\[$GREEN\]$USER@$HOSTNAME \[$BLUE\]\W \[$GREEN\]\$\[\e[0m\] "
export JAVA_HOME=/opt/jdk-21
export PATH=$PATH:$JAVA_HOME/bin
export EDITOR=nvim
export VISUAL=nvim
export SYSTEMD_EDITOR=nvim
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export STEAM_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam"
export STEAM_COMPAT_DATA_PATH="/media/diego/odyssey/SteamLibrary/steamapps/compatdata/489830"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/assets
export TAURI_LINUXDEPLOY=$(which linuxdeploy)
export PATH="$PATH:/usr/games"

source "$HOME/.bashrc_exports"
source "$HOME/.bashrc_functions"
source "$HOME/.bashrc_aliases"
clear
#nitch
pokemon-colorscripts --random --no-title
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init bash)"
