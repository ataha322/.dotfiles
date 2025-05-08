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
alias amxdocker="docker exec -ti --user $USER amxdev /bin/bash"

eta() {
    local clock_status
    if [[ $1 == "in" ]]; then
        clock_status="Arrival"
    elif [[ $1 == "out" ]]; then
        clock_status="Work+Report"
    elif [[ $1 == "break" ]]; then
        clock_status="Break+Start"
    elif [[ $1 == "end" ]]; then
        clock_status="Break+End"
    else
        echo "Usage: eta [in|out|break|end]"
        return 1
    fi
    curl --silent --output /dev/null --show-error --fail 'https://eta.inango.com/timeclock.php' \
        --data-raw "left_fullname=aaltyyev&employee_passwd=Tns_23mic&left_inout=$clock_status&submit_button=Submit"
    if [[ $? -eq 0 ]]; then
        notify-send "ETA" "$clock_status"
    else
        notify-send "ETA" "Failed to clock $clock_status"
    fi
}

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
