export PATH="/mise/shims:$PATH"

eval "$(dircolors)"
alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias l='ls --color=auto -lA'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ga='git add'
alias gc='git commit -v'
alias gca='git commit -av'
alias gcam='git commit -v --amend'
alias gcf='git clean -df'
alias gcl='git cone'
alias gd='git diff'
alias gf='git fetch --prune'
alias gl='git pull'
alias gp='git push origin HEAD'
alias gpf='git push origin HEAD --force-if-includes --force-with-lease'
alias glo='git log --oneline'
alias gm='git merge'
alias gr='git rebase'
alias gss='git status --short'
