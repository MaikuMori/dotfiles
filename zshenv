##########
# PREZTO #
##########

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

###############
# ENVIRONMENT #
###############

export BROWSER='google-chrome-unstable'
export EDITOR="emacsclient -t --socket-name /tmp/emacs1000/server"

export GOPATH=$HOME/GoProjects
export GO15VENDOREXPERIMENT=1

export GPGKEY=24481BFA

export PATH=$GOPATH/bin:$PATH
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.gem/ruby/2.1.0/bin
export PATH=$PATH:$HOME/.cask/bin

export ATOM_REPOS_HOME=$HOME/Projects