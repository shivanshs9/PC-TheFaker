### ENV Variables ###

export ZSH=/home/shivanshs9/.oh-my-zsh
export TERM="xterm-256color"
export EDITOR='vim'
export WORKON_HOME=$HOME/.virtualenvs
export PS2=$'\uf292 \e[1;91mTrace...On!\e[0m \uf0d0   '
export CDPATH=".:$HOME"
export PATH="$PATH:~/.local/bin:."
export WINEPREFIX="/mnt/E/wine"
export PYTHONPATH="/usr/lib/python3.6/site-packages/"
export CLOUDSDK_PYTHON="/usr/bin/python2"

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

### PowerLevel9K ###
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
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(virtualenv status root_indicator background_jobs time)

### Functions ###
code() {
	file="$1.sh";
	if [[ ! -r $file ]]; then
	   echo -e "#!/bin/sh\n# $file: " > $file;
  fi
  if [[ ! -x $file ]]; then 
	   chmod u+x $file 2>/dev/null;
  fi
  vim $file;
	unset file;
}

pip-uninstall() {
	for p in $(pip show "$1" | grep 'Requires:' | tr ',' ' ' | cut -d " " -f2-); do
		pip uninstall $p $2 || break;
	done;
	pip uninstall "$1" $2;
}

adb-log() {
	PID=`adb shell ps | grep -i "$1" | cut -c10-15`;
	adb logcat "*:E" | grep $PID
}

### ALIASES! ###
alias cls="tput reset"
alias rcd="cd - > /dev/null"
alias which="which -a"
alias rm="rm -Iv"
alias wordtoline="tr '\040\011' '\n\n' < " # Converts spaces(\040 in Octal) and tabs(\011) to linefeed(LF, \n, \012)
alias clear-history=": > $HISTFILE"
alias proxify="sudo zsh /home/shivanshs9/Network/redsocks.sh"
alias flushram="free -h && sync && sudo sh -c \"echo 3 >'/proc/sys/vm/drop_caches' && printf '\nRAM Cleared!\n'\" && free -h"
alias flushswap="free -h && sudo swapoff -a && sudo swapon -a && echo '\nSwap Cleared!\n' && free -h"
alias nvidia-status="cat /proc/acpi/bbswitch"
alias https='http --default-scheme=https'
alias pip-check-update='echo "Checking for python package updates..."; pip list --outdated;'
alias pip-update="echo 'Updating python packages'; pip list --outdated --format columns | tail -n +3 | awk '{ print $1}' | xargs -n 1 pip install -U"
alias sysinfo="inxi -Fxxxz"
alias pip-list="pip freeze -l"
alias hist="history | less"

### Oh-My-Zsh ###
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel9k/powerlevel9k"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
export LANG=en_US.UTF-8

### ZSH & Completion ###
setopt appendhistory autocd beep
bindkey -e
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit && compinit

### Autoenv ###
AUTOENV_ENABLE_LEAVE="true"
. ~/.autoenv/activate.sh
antibody bundle < ~/plugins.txt > ~/.zsh_plugins.sh
. ~/.zsh_plugins.sh

### Python Virtualenvwrapper ###
. /usr/bin/virtualenvwrapper_lazy.sh


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

### GCloud stuff ###
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/shivanshs9/google-cloud-sdk/path.zsh.inc' ]; then source '/home/shivanshs9/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/shivanshs9/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/shivanshs9/google-cloud-sdk/completion.zsh.inc'; fi

### pip ZSH Completion ###
function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$(( cword-1 )) \
             PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip

xbindkeys

### RVM ###
export PATH="$PATH:$HOME/.rvm/bin"
