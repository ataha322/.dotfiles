autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

autoload -Uz promptinit && promptinit
prompt_mytheme_setup() {
    PS1='%F{green}%2~%f %F{magenta}%?%f ~> '
}
prompt_themes+=( mytheme )
prompt mytheme

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey -e

# fzf + zsh integration
source <(fzf --zsh)
# Unbind Alt+C
bindkey -r '\ec'  # emacs mode
# Bind Ctrl+F instead
bindkey '^F' fzf-cd-widget

alias ls="ls --color -F"
alias ll="ls --color -alFh"
alias l="ls -CF"
alias sspnd="systemctl suspend"
alias ..="cd .."
alias vim="nvim"
alias kssh="kitten ssh"
alias ssh="ssh -C"
alias rsnk="rsync -havzcP --stats --exclude='.git' --exclude='oe-*' --exclude='output' --exclude='*.o' --exclude='tags' --exclude='*.pdf' --exclude='*.xlsx' --exclude='.cache'"
alias python='python3'
alias svenv='source $(poetry env info --path)/bin/activate || source venv/bin/activate'

renv() {
    python_version="$1"
    # From within the project directory
    deactivate 2>/dev/null || true  # if the venv is active, suppress errors if not
    rm -rf venv/  # remove existing venv
    python_cmd="python${python_version}"
    $python_cmd -m venv venv
    source venv/bin/activate
}

rnm() {
    for file in "$@"; do
        if [ -e "$file" ]; then
            dir=$(dirname "$file")
            filename=$(basename "$file")
            newname=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')
            mv "$file" "$dir/$newname"
        else
            echo "Error: '$file' does not exist"
        fi
    done
}

# export TERM=xterm-256color
precmd () {print -Pn "\e]0;%1~\a"} # set terminal window title

export EDITOR=nvim
