# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Share history between shells
PROMPT_COMMAND='history -a; history -n'

# Search history with Up / Down
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
