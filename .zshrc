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
alias rsnk="rsync -havzcP --stats --exclude='.git' --exclude='oe-*' --exclude='output' --exclude='*.o' --exclude='tags' --exclude='*.pdf' --exclude='*.xlsx'"

# export TERM=xterm-256color

tpd() {
    local TPdevice
    TPdevice=$(xinput | sed -nre '/TouchPad|Touchpad/s/.*id=([0-9]*).*/\1/p')
    
    local state
    state=$(xinput list-props "$TPdevice" | grep "Device Enabled" | grep -o "[01]$")

    if [ "$state" -eq '1' ]; then
        xinput --disable "$TPdevice" && notify-send -i emblem-nowrite "Touchpad" "Disabled"
    else
        xinput --enable "$TPdevice" && notify-send -i emblem-nowrite "Touchpad" "Enabled"
    fi
}

pstkys() {
    xclip -selection clipboard -out | tr \\n \\r | xdotool selectwindow windowfocus type --clearmodifiers --delay 30 --window %@ --file -
}

cdup() {
    if ! [[ $1 =~ ^[0-9]+$ ]] ; then
        echo "error: Not a number" >&2; return 1
    fi
    cd $(printf "%0.0s../" $(seq 1 $1))
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
