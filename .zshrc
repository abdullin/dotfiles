# File in general is based on the dotfiles from Gary Bernhard
# https://github.com/garybernhardt/dotfiles/blob/master/.zshrc

# DOTFILES SUPPORT ==================================================
# this is based on the idea from https://news.ycombinator.com/item?id=11070797
# with some modifications 
# to create a new repo:
#    git init --bare $HOME/.dotfiles
# then switch into the dotfiles mode (defined in the function below).
# There will be a lot of noise in there. I prefer to add everythint to ignores
# Alternative is:
#   git config --local status.showUntrackedFiles no

DOTFILES_PROMPT='%{%B%}%{%F{red}%}git->dot%{%f%}%{%b%}'

function dotfiles() {
  if [[ "$RPROMPT" == "" ]]; then
    echo "Entering dotfiles mode. Write dotfiles again to leave it"
    alias git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    RPROMPT=$DOTFILES_PROMPT
  elif [[ "$RPROMPT" == "$DOTFILES_PROMPT" ]]; then
    echo "Leaving dotfiles mode"
    unalias git
    RPROMPT=""
  else
    echo "RPROMPT is set to something unexpected!"
  fi
}
# PROMPT ============================================================
# Allow dynamic command prompt
setopt prompt_subst
# Make sure that vcs_info function is available:
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
# Update each time new prompt is rendered: 
function precmd() { 
  vcs_info
}

# Show base (.git) directory, current branch and path within a repo: 
zstyle ':vcs_info:*' formats '(%{%F{red}%}%b%{%f%})'

# show vcs info in the prompt
# %d - directory
# %n - username
# %m - short hostname
PROMPT='%(?.%{%F{green}%}.%{%F{red}%})%n@%m%{%f%} %{%B%}%1~%{%f%} ${vcs_info_msg_0_}> %{%f%}%{%b%}'

# Enable completion
autoload -U compinit
compinit -D
# choose tab completion options with arrow keys
zstyle ':completion:*' menu select


# Colorize terminal
alias ls='ls -G'
alias ll='ls -lG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"


# Use C-x C-e to edit the current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Path to your oh-my-zsh configuration.
#ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="robbyrussell"

alias ec='emacsclient -c'


export PATH="/usr/local/sbin:/usr/local/bin:${PATH}"
# include bin from the dotfiles
export PATH="$HOME/bin:$PATH"

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE


# search with up/down
# this works when I mosh to ubuntu
bindkey ${terminfo[kcuu1]} history-beginning-search-backward
bindkey ${terminfo[kcud1]} history-beginning-search-forward
# this works in iTerm on OSX
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward


test -f $HOME/.bash_profile && source $HOME/.bash_profile

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


# Switch projects
function p() {
    # grab list of projects + list of aliases
    local list=$( ls ~/proj ; cat ~/proj/.alias 2>/dev/null)
    # run through the selector
    local proj=$(echo $list | selecta)
    if [[ -n "$proj" ]]; then
        cd ~/proj/$proj
        # Ruby activation with chruby and gem_home
        if [[ -e "Gemfile" ]]; then
            local ruby_version
            ruby_version=$(ruby -ne $'print $1 if $_ =~ /ruby [\'"]([0-9.]+)[\'"]/' Gemfile)
            chruby "$ruby_version"
            gem_home .
        fi
        # Python activation
        if [[ -e "venv/bin/activate" ]]; then
            clear
            source venv/bin/activate
        fi
        # load secrets
        if [[ -d ~/secrets/$proj ]]; then
            . ~/secrets/$proj/secrets.sh
        fi
    fi
}

# golang
export PATH=$PATH:$HOME/proj/go/bin

# PYTHON ==========================================
export PATH=$PATH:$(python3 -m site --user-base)/bin

# Activate the closest virtualenv by looking in parent directories.
function activate_venv() {
    if [ -f venv/bin/activate ]; then . venv/bin/activate;
    elif [ -f ../venv/bin/activate ]; then . ../venv/bin/activate;
    elif [ -f ../../venv/bin/activate ]; then . ../../venv/bin/activate;
    elif [ -f ../../../venv/bin/activate ]; then . ../../../venv/bin/activate;
    fi
}


# dotnet
export PATH="$PATH:$HOME/.dotnet/tools"



# changes the current ruby
# https://github.com/postmodern/chruby
if [ -f /usr/local/share/chruby/chruby.sh ]; then 
  source /usr/local/share/chruby/chruby.sh
fi
# a tool for changing $GEM_HOME
# https://github.com/postmodern/gem_home
if [ -f /usr/local/share/gem_home/gem_home.sh ]; then
  source /usr/local/share/gem_home/gem_home.sh
fi
