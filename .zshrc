# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

#alias vim='emacsclient -t'
#alias vi='emacsclient -t'i

alias e='emacsclient -t'
alias ec='emacsclient -c'
# DFS - DotFileS - git alias for working with the dotfiles
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

plugins=(git autojump command-not-found)

source $ZSH/oh-my-zsh.sh

export PATH="/usr/local/sbin:/usr/local/bin:${PATH}"
export PATH="$HOME/bin:$PATH"

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE



# search with ctrl+up/ctrl+down
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward

test -f $HOME/.bash_profile && source $HOME/.bash_profile
test -f $HOME/.ssh/secrets && source $HOME/.ssh/secrets

# Stop wget from creating ~/.wget-hsts file. I don't care about HSTS (HTTP
# Strict Transport Security) for wget; it's not as if I'm logging into my bank
# with it.
alias wget='wget --no-hsts'

# Edit a note
function n() {
    local note=$(find ~/notes/* | selecta)
    if [[ -n "$note" ]]; then
        (cd ~/notes && vi "$note")
    fi
}

export GOPATH=$HOME/proj/go
export PATH=$PATH:$HOME/proj/go/bin
export PATH=$PATH:/usr/local/opt/go/libexec/bin


# pipenv
export PATH=$PATH:$(python3 -m site --user-base)/bin


autoload -U +X bashcompinit && bashcompinit
