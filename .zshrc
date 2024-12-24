ZSH="/root/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker docker-compose)
source $ZSH/oh-my-zsh.sh

# Aliases utiles
alias ll="ls -la"
alias c="clear"
alias ..="cd .."
alias ...="cd ../.."

# Configuration pour le développement
export PATH=$PATH:/root/.local/bin 