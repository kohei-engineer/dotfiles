# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Disable terminal flow control so Ctrl+S remains available to applications.
stty -ixon

# Share history between shells
PROMPT_COMMAND='history -a; history -n'

# Search history with Up / Down
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
