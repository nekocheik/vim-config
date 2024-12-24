# Utiliser une image multi-architecture
FROM nickblah/lua:5.4.7-ubuntu

# Définir le frontend Debian pour éviter les interactions
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    curl \
    git \
    fzf \
    ripgrep \
    tree \
    xclip \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    tzdata \
    software-properties-common \
    tmux \
    luajit \
    luarocks \
    zsh \
    fonts-powerline \
    && apt-get clean

# Installation de Oh My Zsh et plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configuration de zsh
RUN echo 'ZSH="/root/.oh-my-zsh"\n\
ZSH_THEME="agnoster"\n\
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker docker-compose)\n\
source $ZSH/oh-my-zsh.sh\n\
\n\
# Aliases utiles\n\
alias ll="ls -la"\n\
alias c="clear"\n\
alias ..="cd .."\n\
alias ...="cd ../.."\n\
\n\
# Configuration pour le développement\n\
export PATH=$PATH:/root/.local/bin' > /root/.zshrc

# Définir zsh comme shell par défaut
RUN chsh -s $(which zsh)

# Installer Neovim
RUN add-apt-repository ppa:neovim-ppa/stable \
    && apt-get update \
    && apt-get install -y neovim

# Créer les répertoires nécessaires
RUN mkdir -p /root/.config/nvim/lua/plugins

# Copier la configuration
COPY .config/nvim/ /root/.config/nvim/

# Installer Packer
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    /root/.local/share/nvim/site/pack/packer/start/packer.nvim

# Installer les plugins Neovim
RUN python3 -m venv /root/nvim-venv && \
    /root/nvim-venv/bin/pip install pynvim && \
    npm install -g neovim

# Définir le répertoire de travail
WORKDIR /root/workspace

# Commande par défaut (maintenant zsh au lieu de nvim)
CMD ["zsh"]