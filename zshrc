###############
# ZSH OPTIONS #
###############

# Change dir by just typing it's name.
setopt auto_cd
# Auto pushd when changing directories.
setopt auto_pushd
# Don't push dublicate direcories.
setopt pushd_ignore_dups
# Careful `rm`s.
setopt rm_star_wait
# Timestamps and time in history.
setopt extended_history
# When cleaning history remove oldest dups first.
setopt hist_expire_dups_first
# Remove comand from history list if first char is space.
setopt hist_ignore_space
# Cleanup commands in history.
setopt hist_reduce_blanks
# Multiple streams automatically.
setopt multios

# Add our custom compleations.
fpath=(/usr/share/bash-completion/bash_completion $fpath)
fpath=(~/.zcomplete $fpath)

##########
# PREZTO #
##########

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

#########
# ALIAS #
#########

# Emacs with correct daemon settings for Archlinux.
alias e="emacsclient -t --socket-name /tmp/emacs1000/server"
alias emc="emacsclient -n -c --socket-name /tmp/emacs1000/server"

# Make these commands ask before clobbering a file. Use -f to override.
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias lt="lt"
alias ls="exa"

alias archrss="rsstail -u https://aur.archlinux.org/rss/ -n 10 -d -N -l"

# Pacman
alias pacman="sudo pacman"
alias pacup="sudo pacman -Syu"
alias pacrank="rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup | sudo tee /etc/pacman.d/mirrorlist"

# Fasd
alias a="fasd -a"        # any
alias s="fasd -si"       # show / search / select
alias d="fasd -d"        # directory
alias f="fasd -f"        # file
alias sd="fasd -sid"     # interactive directory selection
alias sf="fasd -sif"     # interactive file selection
alias z="fasd_cd -d"     # cd, same functionality as j in autojump
alias zz="fasd_cd -d -i" # cd with interactive selection

# npm
alias npup="sudo npm -g update --python=/usr/bin/python"

# Hub
alias git="hub"

# Random
alias beepbeep="paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"

#############
# FUNCTIONS #
#############

# Launch and detach an app.
launch() {
    ( $* &> /dev/null & )
}

#####################
# VIRTUALENVWRAPPER #
#####################

if [ -f /usr/bin/virtualenvwrapper.sh ]; then
   export WORKON_HOME=~/.virtualenvs
   export PROJECT_HOME=~/Projects
   export VIRTUAL_ENV_DISABLE_PROMPT=true
   source /usr/bin/virtualenvwrapper.sh
fi

######
# UI #
######

# Base16 Shell
BASE16_SHELL=$HOME/.config/base16-shell/scripts/base16-monokai.sh
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Powerline
if [ -f ~/.local/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh ]; then
   powerline-daemon -q
   source ~/.local/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
else
    zstyle ':prezto:module:prompt' theme 'powerlevel9k'
fi

#######
# NVM #
#######

if [ -f /usr/share/nvm/init-nvm.sh ]; then
   source /usr/share/nvm/init-nvm.sh
fi

###########
# Kubectl #
###########

if [ -f /opt/google-cloud-sdk/bin/kubectl ]; then
    source <(kubectl completion zsh)
fi

####################
# Google Cloud SDK #
####################

if [ -f /opt/google-cloud-sdk/completion.zsh.inc ]; then
    source /opt/google-cloud-sdk/completion.zsh.inc
fi
