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

# install zsh and make it default by adding /usr/bin/zsh to /etc/passwd
# to pull things on a new machine:
# REPO=https://github.com/abdullin/dotfiles.git
# or
# REPO=git@github.com:abdullin/dotfiles.git

# git clone --bare $REPO $HOME/.dotfiles
# git --work-tree=$HOME --git-dir=$HOME/.dotfiles/ checkout
# git --work-tree=$HOME --git-dir=$HOME/.dotfiles/ submodule update --init --recursive
# then restart the terminal

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

alias dotpf="git --work-tree=$HOME --git-dir=$HOME/.dotfiles/ pf"

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
# If you get compinit to complain on mac, remove write permissions on the faulty files
# compaudit | xargs chmod go-w
compinit -D
# choose tab completion options with arrow keys
zstyle ':completion:*' menu select


# Colorize terminal
alias ls='ls -G'
alias ll='ls -lG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# Always enable colored `grep` output`
alias grep="grep --color=auto"

# Use C-x C-e to edit the current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

alias ec='emacsclient -c'

export PATH="/usr/local/sbin:/usr/local/bin:${PATH}"
# include bin from the dotfiles
# also bin from the .local, if present
export PATH="$HOME/bin:$PATH:$HOME/.local/bin"

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Nicer history
#
export HISTSIZE=100000                   # big big history
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTFILESIZE=100000               # big big history

export HISTFILE="$HOME/.history"
export SAVEHIST=100000

# from here https://unix.stackexchange.com/a/575102 
setopt appendhistory
setopt INC_APPEND_HISTORY  
setopt SHARE_HISTORY



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

alias heatseeker=$(~/bin/bin-for-this-platform heatseeker)
alias fd=$(~/bin/bin-for-this-platform fd)
# By default, ^S freezes terminal output and ^Q resumes it. Disable that so
# that those keys can be used for other things.
unsetopt flowcontrol
# Run heatseeker in the current working directory, appending the selected path, if
# any, to the current command.
function insert-heatseeker-path-in-command-line() {
    local selected_path
    # Print a newline or we'll clobber the old prompt.
    echo
    # Find the path; abort if the user doesn't select anything.
    selected_path=$(fd -t f . | heatseeker) || return
    # Escape the selected path, since we're inserting it into a command line.
    # E.g., spaces would cause it to be multiple arguments instead of a single
    # path argument.
    selected_path=$(printf '%q' "$selected_path")
    # Append the selection to the current command buffer.
    eval 'LBUFFER="$LBUFFER$selected_path "'
    # Redraw the prompt since heatseeker has drawn several new lines of text.
    zle reset-prompt
}
# Create the zle widget
zle -N insert-heatseeker-path-in-command-line
# Bind the key to the newly created widget
bindkey "^S" "insert-heatseeker-path-in-command-line"


# Switch projects
function p() {
    # grab list of projects + list of aliases
    local list=$( ls ~/proj ; cat ~/proj/.alias 2>/dev/null)
    # run through the selector
    local proj=$(echo $list | heatseeker)
    if [[ -n "$proj" ]]; then

        cd ~/proj/$proj

        # set iterm tab to the project name
        if [[ -n "$ITERM_PROFILE" ]]; then
          echo -ne "\033]0;$proj\007"
        fi

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
            echo "."
            source ~/secrets/$proj/secrets
        fi
    fi
}

# golang
export PATH=$PATH:$HOME/go/bin

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
