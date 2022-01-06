
# profile

# golang related envs
export GOPATH=$HOME/go
# export GOROOT=$(brew --prefix go@1.12)/libexec
# export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export GONOPROXY=$GOPRIVATE
export GOPRIVATE=*.ozon.ru
export GOPROXY="https://proxy.golang.org|direct"
export GONOSUMDB=$GOPRIVATE
export GOSUMDB=sum.golang.org
export GO111MODULE=on
export GOINSECURE=none

# csharp related envs
DOTNET_CLI_TELEMETRY_OPTOUT=0

# other related envs
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export LC_ALL='en_US.UTF-8'
export PS1="\[\033[38;5;5m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;10m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\] \[\033[38;5;14m\]\$(get_branch)\[$(tput sgr0)\]"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export BASH_SILENCE_DEPRECATION_WARNING=1
# export GITLAB_TOKEN=

# history size
export HISTFILESIZE=1000000
export HISTSIZE=1000000

alias k="kubectl"

alias ls='ls -G'
alias grep='grep --color=auto'
alias c='clear'
alias sed='gsed'
alias grpcurl='grpcurl -plaintext'

getip() {
    dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"'
}

gitsetzero() {
    git init
    git config --local --add user.email morgoevm@gmail.com
    git config --local --add user.name zerospiel
}

getgot() {
    go install github.com/melbahja/got/cmd/got@latest
}

getbuf() {
    argl=${#@}
    v=""
    if [[ $argl -eq 0 ]]
    then
        v=$(git ls-remote --tags --sort v:refname --exit-code --refs https://github.com/bufbuild/buf | tail -n1 | cut -d '/' -f3)
    else
        v="v$1"
    fi
    echo $v
    rm $GOBIN/buf && got -o $GOBIN/buf https://github.com/bufbuild/buf/releases/download/$v/buf-`uname -s`-`uname -m` && chmod +x $GOBIN/buf
}

get_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d ; s/* \(.*\)/(\1) /'
}

qq() {
    clear
    
    logpath="$TMPDIR/q"
    if [[ -z "$TMPDIR" ]]; then
        logpath="/tmp/q"
    fi
    
    if [[ ! -f "$logpath" ]]; then
        echo 'Q LOG' > "$logpath"
    fi
    
    tail -100f -- "$logpath"
}

rmqq() {
    logpath="$TMPDIR/q"
    if [[ -z "$TMPDIR" ]]; then
        logpath="/tmp/q"
    fi
    if [[ -f "$logpath" ]]; then
        rm "$logpath"
    fi
    qq
}

