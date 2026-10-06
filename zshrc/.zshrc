# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt autocd
unsetopt beep
bindkey -e

# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit && compinit
autoload -Uz colors && colors

setopt PROMPT_SUBST

PROMPT='%F{#c6a0f6}%n%f at %F{#c6a0f6}%m%f  %F{#8aadf4}%B%1~%b%f %F{#7dc4e4}%B$(git branch --show-current 2>/dev/null)%b%f
%F{#c6a0f6}%#%f '

export EDITOR='nvim'
export JAVA_HOME="/usr/lib/jvm/java-24-openjdk/"
export PATH="$JAVA_HOME/bin:$PATH"
source ~/.zsh_functions.zsh
source ~/.zsh_alias.zsh
clear
pokemon-colorscripts --random --no-title

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
