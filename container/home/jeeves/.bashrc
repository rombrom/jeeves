export PATH="/mise/shims:$PATH"

# Very dumb but when in project directories with other tools installed
# pi won't boot because there's no default global node version.
alias pi='mise exec node@26 -- pi'

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
