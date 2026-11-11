#!/bin/sh

export DOTFILES="$HOME/dotfiles"

echo "Setting up your Mac..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
else
  echo "Xcode Command Line Tools already installed."
fi

# Check for Oh My Zsh and install if we don't have it
if ! [ -d $HOME/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Link dotfiles without discarding an existing file or link.
link_dotfile() {
  link_source=$1
  link_target=$2

  if [ -L "$link_target" ] && [ "$(readlink "$link_target")" = "$link_source" ]; then
    return
  fi

  if [ -e "$link_target" ] || [ -L "$link_target" ]; then
    link_backup="${link_target}.backup.$(date +%Y%m%d%H%M%S)"
    while [ -e "$link_backup" ] || [ -L "$link_backup" ]; do
      link_backup="${link_backup}.1"
    done
    mv "$link_target" "$link_backup" || return 1
    echo "Backed up $link_target to $link_backup"
  fi

  ln -s "$link_source" "$link_target"
}

link_dotfile "$DOTFILES/dotfiles/.Brewfile" "$HOME/.Brewfile"
link_dotfile "$DOTFILES/dotfiles/.gitconfig" "$HOME/.gitconfig"
link_dotfile "$DOTFILES/dotfiles/.gitignore_global" "$HOME/.gitignore_global"
link_dotfile "$DOTFILES/dotfiles/.hushlogin" "$HOME/.hushlogin"
link_dotfile "$DOTFILES/dotfiles/.inputrc" "$HOME/.inputrc"
link_dotfile "$DOTFILES/dotfiles/.zshenv" "$HOME/.zshenv"
link_dotfile "$DOTFILES/dotfiles/.zshrc" "$HOME/.zshrc"
link_dotfile "$DOTFILES/dotfiles/aliases.zsh" "$HOME/aliases.zsh"
link_dotfile "$DOTFILES/dotfiles/path.zsh" "$HOME/path.zsh"

# Add autosuggestion for zsh and Make zsh default shell
chsh -s $(which zsh)

# Install Homebrew packages
brew bundle --cleanup --global -v; brew cu -f -a

# Create a Sites directory
# This is a default directory for macOS user accounts but doesn't comes pre-installed
mkdir -p $HOME/Code

# Set macOS preferences - we will run this last because this will reload the shell
source $DOTFILES/install/macos.sh

# Reload to apply changes
exec ${SHELL} -l
