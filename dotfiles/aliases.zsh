# Shortcuts
alias co="cd ~/Code"

alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias l="gls -AhlFo --color --group-directories-first"
alias meh="echo '¯\_(ツ)_/¯' | pbcopy"

# Symfony
alias sf="symfony"
alias con="sf console"
alias c="sf composer"
alias cc="con cache:clear"
alias rmc="rm -rf var/cache var/log"

# Verify CS & PHPStan

# Tools
alias stan="vendor/bin/phpstan analyse "
alias cs="vendor/bin/ecs check --fix "
alias rec="vendor/bin/rector process "
alias grump="stan && cs"

# PHP
alias cfresh="rm -rf vendor/ composer.lock && composer i"
alias php81="brew link --overwrite php@8.1"
alias php82="brew link --overwrite php@8.2"
alias php83="brew link --overwrite php@8.3"
alias php84="brew link --overwrite php@8.4"

# JS
alias nfresh="rm -rf node_modules/ yarn.lock && yarn install"

# Git
alias commit="git add . && git commit -s -m"
alias nah="git clean -df && git reset --hard"
alias pull="git pull"
alias push="git push"
alias wip="commit wip -n"

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get macOS Software Updates, and update Homebrew, npm and their installed packages and composer global packages
alias update='sudo softwareupdate -i -a; brew bundle --cleanup --global -v; brew cu -f -a'
alias upd='brew bundle --cleanup --global -v; brew cu -f -a'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'
