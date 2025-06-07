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

bindkey -e

alias ls="ls --color -F"
alias ll="ls --color -alFh"
alias l="ls -CF"
alias sspnd="systemctl suspend"
alias ..="cd .."
alias vim="nvim"
alias ltx="pdflatex -file-line-error -halt-on-error -interaction=nonstopmode"
alias kssh="kitten ssh"
alias ssh="ssh -C"
alias rsnk="rsync -havzcP --stats --exclude='.git' --exclude='oe-*' --exclude='output' --exclude='*.o' --exclude='tags' --exclude='*.pdf' --exclude='*.xlsx' --exclude='.cache'"

# export TERM=xterm-256color
