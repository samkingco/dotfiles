###############################################################################
# Prompt                                                                      #
###############################################################################

setopt PROMPT_SUBST
PROMPT='%B%F{yellow}%1~%b%F{magenta}$(git_prompt_info) %B%F{yellow}→%f%b '

###############################################################################
# Environment & Path                                                          #
###############################################################################

# Editor
export EDITOR="zed"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Path
export PATH="/usr/local/bin:$PATH"

# pnpm
export PNPM_HOME="/opt/homebrew/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun
export BUN_INSTALL="/opt/homebrew/opt/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# foundry
export PATH="$PATH:$HOME/.foundry/bin"

###############################################################################
# Node Version Manager                                                        #
###############################################################################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

###############################################################################
# Shell Options                                                               #
###############################################################################

# Auto-completion
if [ -n "$ZSH_VERSION" ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    zstyle ':completion:*' menu select
fi

# History
export HISTSIZE=32768
export SAVEHIST=$HISTSIZE
if [ -n "$ZSH_VERSION" ]; then
    setopt HIST_IGNORE_DUPS      # Don't record duplicates
    setopt HIST_IGNORE_SPACE     # Don't record commands starting with space
    setopt HIST_VERIFY           # Show command with history expansion before running it
    setopt SHARE_HISTORY         # Share history between sessions
    setopt EXTENDED_HISTORY      # Add timestamps to history
fi

# Colors
export CLICOLOR=1

###############################################################################
# Aliases                                                                     #
###############################################################################

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Scripts
alias dotsetup="$HOME/Code/dotfiles/scripts/install.sh"
alias defaults="$HOME/Code/dotfiles/scripts/configure-macos.sh"

# GIT
alias g='git'
alias gdm="git branch --merged main | grep -v main | xargs -n 1 git branch -d"

# List files
alias l="ls -lF"
alias lsa="ls -laF"
alias lsd='ls -lF | grep "^d"'
alias c='pygmentize -O style=colorful -g'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Package updates
alias update='brew update; brew upgrade; brew cleanup; npm update -g; pnpm update-self'

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy && echo '=> Public key copied to pasteboard.'"

# PNPM version 8
alias pnpm8="npx pnpm@8"

###############################################################################
# Functions                                                                   #
###############################################################################

# Confirmation prompt
function confirm() {
  read -r -p "${1:-Are you sure? [y/N]} " response
  case $response in
    [yY][eE][sS]|[yY]) true ;;
    *) false ;;
  esac
}

# Create and enter directory
function md() {
  mkdir -p "$@" && cd "$@"
}

# cd into whatever is the frontmost Finder window.
function cdf() {
  cd "`osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'`"
}

# Git helpers
function currepo() {
  git config --get remote.origin.url | sed 's/.*@\(.*\)/\1/' | sed 's/\(.*\):\(.*\)/\1\/\2/' | sed 's/\(.*\)\.git/\1/'
}

function curbranch() {
  git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'
}

function git_prompt_info() {
  local ref dirty
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  dirty=$(git status --porcelain 2> /dev/null | tail -n1)
  echo "/${ref#refs/heads/}${dirty:+ *}"
}

# Copy with progress
function cpp() {
  rsync -WavP --human-readable --progress $1 $2
}

# Get gzipped size
function gz() {
  echo "orig size    (bytes): "
  cat "$1" | wc -c
  echo "gzipped size (bytes): "
  gzip -c "$1" | wc -c
}

# Display a terminal colour grid, useful for creating a theme
function colorgrid() {
  iter=16
  while [ $iter -lt 52 ]
  do
    second=$[$iter+36]
    third=$[$second+36]
    four=$[$third+36]
    five=$[$four+36]
    six=$[$five+36]
    seven=$[$six+36]
    if [ $seven -gt 250 ];then seven=$[$seven-251]; fi

    echo -en "\033[38;5;$(echo $iter)m█ "
    printf "%03d" $iter
    echo -en "   \033[38;5;$(echo $second)m█ "
    printf "%03d" $second
    echo -en "   \033[38;5;$(echo $third)m█ "
    printf "%03d" $third
    echo -en "   \033[38;5;$(echo $four)m█ "
    printf "%03d" $four
    echo -en "   \033[38;5;$(echo $five)m█ "
    printf "%03d" $five
    echo -en "   \033[38;5;$(echo $six)m█ "
    printf "%03d" $six
    echo -en "   \033[38;5;$(echo $seven)m█ "
    printf "%03d" $seven

    iter=$[$iter+1]
    printf '\r\n'
  done
}
