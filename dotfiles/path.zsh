# Global path
export GOPATH=$HOME/go
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$HOME/.local/bin:/Applications/Docker.app/Contents/Resources/bin:$GOPATH/bin:$PATH

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# GNU coreutils stay g-prefixed (gls, gdate...). Putting gnubin in PATH breaks some Homebrew builds.
# Strip it in case a parent process passed it down.
path=(${path:#*/coreutils/libexec/gnubin})

