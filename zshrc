# Executes commands at the start of an interactive session.

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# ENV
export BROWSER='google-chrome-unstable'
export EDITOR="emacsclient -t --socket-name /tmp/emacs1000/server"
export GOPATH=$HOME/GoProjects
export GPGKEY=24481BFA

export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.gem/ruby/2.1.0/bin
export PATH=$PATH:$HOME/.cask/bin

# Alias

# Emacs with correct daemon settings for Archlinux.
alias e="emacsclient -t --socket-name /tmp/emacs1000/server"
alias emc="emacsclient -c --socket-name /tmp/emacs1000/server"

# Make these commands ask before clobbering a file. Use -f to override.
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias lt="lt"

alias archrss="rsstail -u https://aur.archlinux.org/rss/ -n 10 -d -N -l"

# Pacman
alias pacman="sudo pacman"
alias pacup="sudo pacman -Syu"
alias yaup="yaourt -Syua"

# Fasd
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection

# npm
alias npup="sudo npm -g update --python=/usr/bin/python"

# Functions
lock() {
    if [ $(ps aux | grep -e 'gnome-screensaver$' | grep -v grep | wc -l | tr -s "\n") -eq 0 ];
    then
    ( gnome-screensaver &> /dev/null & );  fi

    gnome-screensaver-command -l
}

launch() {
    ( $* &> /dev/null & )
}

# VirtualEnvWrapper
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=~/Projects
export VIRTUAL_ENV_DISABLE_PROMPT=true
source /usr/bin/virtualenvwrapper.sh

# When the current working directory changes,
# run a method that checks for a .env file,
# then sources it. Happy days.
autoload -U add-zsh-hook
load-local-conf() {
    # Check file exists, is regular file and is readable:
    if [[ -f .env && -r .env ]]; then
        source .env
    fi
}
add-zsh-hook chpwd load-local-conf

# Shell colors.
# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-monokai.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Powerline
powerline-daemon -q
. /usr/share/zsh/site-contrib/powerline.zsh

# Atom
export ATOM_REPOS_HOME=$HOME/Projects

# Hub
eval "$(hub alias -s)"
