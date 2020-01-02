#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Shivansh Saini <shivanshs9@gmail.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

### ENV Variables ###
export PS2=$'\uf292 \e[1;91mTrace...On!\e[0m \uf0d0   '
export CDPATH=".:$HOME"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$HOME/.rbenv/bin:$PATH:/opt/android-studio/jre/bin:$HOME/.gem/ruby/2.6.0/bin:$GOBIN"
export EDITOR="vim"
export XAUTHORITY=~/.Xauthority
export DISPLAY=":0.0"
export WINEPREFIX="/mnt/extra/win7-x64"
export WINEARCH="win64"

### PowerLevel9K/10K ###
DEFAULT_USER="$USER"
POWERLEVEL9K_ALWAYS_SHOW_USER=false
POWERLEVEL9K_CONTEXT_TEMPLATE="%n@$(hostname -f)"
POWERLEVEL9K_MODE='nerdfont-complete'
# POWERLEVEL9K_HOME_ICON="\uf015"
# POWERLEVEL9K_HOME_SUB_ICON="\uf07c "
# POWERLEVEL9K_FOLDER_ICON="\uf07b "
# POWERLEVEL9K_BACKGROUND_JOBS_ICON="\uf085 "

POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
POWERLEVEL9K_SHORTEN_DELIMITER="..."
POWERLEVEL9K_DIR_SHOW_WRITABLE=true
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_DIR_PATH_SEPARATOR="%F{white} $(print $'\uE0B1') %F{white}"
POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND='001'
POWERLEVEL9K_TIME_FORMAT="%D{\uf017 %H:%M:%S}"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv status root_indicator background_jobs command_execution_time)

### ALIASES! ###
alias cls="tput reset"
alias rcd="cd - > /dev/null"
alias which="which -a"
alias wordtoline="tr '\040\011' '\n\n' < " # Converts spaces(\040 in Octal) and tabs(\011) to linefeed(LF, \n, \012)
alias https='http --default-scheme=https'
alias pip-check-update='echo "Checking for python package updates..."; pip list --outdated;'
alias pip-update="echo 'Updating python packages'; pip list --outdated --format columns | tail -n +3 | awk '{ print $1}' | xargs -n 1 pip install -U"
alias hist="history | less"
alias nvidia-status="cat /proc/acpi/bbswitch"

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd beep extendedglob notify
bindkey -e
# End of lines configured by zsh-newuser-install

### Source Prezto ###
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

eval "$(rbenv init -)"
eval "$(hub alias -s)"

function win32() {
	WINEARCH="win32" WINEPREFIX="/mnt/extra/win7-x86" "$@"
}

### HACK TO FIX SPECIAL KEYS IN ZSH ###
bindkey '^R' history-incremental-pattern-search-backward    # Ctrl + R
bindkey "$terminfo[kcuu1]" up-line-or-search                # Up
bindkey "$terminfo[kcud1]" down-line-or-search              # Down
bindkey "\E[1;3C" forward-char                              # Alt + Right
bindkey "\E[1;3D" backward-char                             # Alt + Left
bindkey "^X" execute-named-cmd                              # Ctrl + X

## For CUA-style selection

self-insert() {
    if ((REGION_ACTIVE)) then
       zle kill-region
    fi
    zle .self-insert
}
zle -N self-insert

r-delregion() {
    if ((REGION_ACTIVE)) then
       zle kill-region
    else
       zle $1
    fi
}

r-deselect() {
    ((REGION_ACTIVE = 0))
    zle $*
}

r-deselect-left() {
    if ((REGION_ACTIVE)) then
      if [[ $MARK -lt $CURSOR ]]
      then
        zle exchange-point-and-mark
      fi
      ((REGION_ACTIVE = 0))
      zle forward-char
    fi
    zle $*
}

r-deselect-right() {
    if ((REGION_ACTIVE)) then
      if [[ $MARK -gt $CURSOR ]]
      then
        zle exchange-point-and-mark
      fi
      ((REGION_ACTIVE = 0))
      zle backward-char
    fi
    zle $*
}

r-select() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle $*
}

r-prepend() {
  if [[ $BUFFER != "$@ "* ]]; then
    BUFFER="$@ $BUFFER"; CURSOR+=$(echo -n "$@ " | wc -c)
  fi
}

r-copy() {
  zle $*
  print -rn $CUTBUFFER | xsel --clipboard --input
  zle exchange-point-and-mark   # Keep the selection, but restore cursor position
}

r-paste() {
  CUTBUFFER=$(xsel --clipboard --output </dev/null)
  zle yank
}

for key kcap seq mode widget (
    sleft   kLFT    $'\E[1;2D' select backward-char
    sright  kRIT    $'\E[1;2C' select forward-char
    sup     kri     $'\E[1;2A' select 'beginning-of-line exchange-point-and-mark'
    sdown   kind    $'\E[1;2B' select 'end-of-line exchange-point-and-mark'
    send    kEND    $'\E[1;2F' select end-of-line
    shome   kHOM    $'\E[1;2H' select beginning-of-line
    left    kcub1   $'\EOD' deselect-left 'backward-char'
    right   kcuf1   $'\EOC' deselect-right 'forward-char'
    end     kend    $'\EOF' deselect end-of-line
    home    khome   $'\EOH' deselect beginning-of-line
    csleft  x       $'\E[1;6D' select backward-word
    csright x       $'\E[1;6C' select forward-word
    csend   x       $'\E[1;6F' select end-of-line
    cshome  x       $'\E[1;6H' select beginning-of-line
    cleft   x       $'\E[1;5D'   deselect-left backward-word
    cright  x       $'\E[1;5C'   deselect-right forward-word
    del     kdch1   $'\E[3~' delregion delete-char
    bs      x       $'^?' delregion backward-delete-char
    copy    x       $'^[c' copy copy-region-as-kill
    cut     x       $'^[x' copy kill-region
    paste   x       $'^[v' paste kill-region
    sudo    x       $'^[s' prepend sudo
  ) {
  eval "key-$key() r-$mode $widget"
  zle -N key-$key
  bindkey ${terminfo[$kcap]-$seq} key-$key
}

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl true
zstyle :compinstall filename '/home/shivanshs9/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/shivanshs9/google-cloud-sdk/path.zsh.inc' ]; then . '/home/shivanshs9/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/shivanshs9/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/shivanshs9/google-cloud-sdk/completion.zsh.inc'; fi

# added by travis gem
[ -f /home/shivanshs9/.travis/travis.sh ] && source /home/shivanshs9/.travis/travis.sh

unalias rm
