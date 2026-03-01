# Global path
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/.local/bin:/Applications/Docker.app/Contents/Resources/bin:$PATH

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# Make sure coreutils are loaded before system commands
# I've disabled this for now because I only use "ls" which is
# referenced in my aliases.zsh file directly.
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

