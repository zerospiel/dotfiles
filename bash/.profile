
# profile

# golang related envs
export GOPATH=$HOME/go
# export GOROOT=$(brew --prefix go@1.12)/libexec
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export GONOPROXY=*.ozon.ru
export GOPRIVATE=*.ozon.ru
export GOPROXY="https://proxy.golang.org|direct"
export GONOSUMDB=$GONOPROXY
export GOSUMDB=sum.golang.org
export GO111MODULE=auto
export GOINSECURE=none

# csharp related envs
DOTNET_CLI_TELEMETRY_OPTOUT=0

# other related envs
# export PATH="/usr/local/opt/helm@2/bin:$GOBIN:$PATH"
export PATH="$GOBIN:$PATH"
export LC_ALL='en_US.UTF-8'
export PS1="\[\033[38;5;5m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;10m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\] \[\033[38;5;14m\]\$(get_branch)\[$(tput sgr0)\]"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export BASH_SILENCE_DEPRECATION_WARNING=1
export GITLAB_TOKEN=some_token

alias k="kubectl"
alias clickconnect='docker run -it --rm yandex/clickhouse-client --host $1 --user $2 --password $3 --database $4'
alias fixgovno='launchctl unload /Library/LaunchAgents/com.trusourcelabs.NoMAD.plist; killall NoMAD'
alias etcdctl2='ETCDCTL_API=2 etcdctl'
alias etcdstg='etcdctl2 --endpoints `cat $HOME/.pki/eps_stg` --ca-file $HOME/.pki/ca_stg --cert-file $HOME/.pki/cert_stg --key-file $HOME/.pki/key_stg'
alias etcdprod='etcdctl2 --endpoints `cat $HOME/.pki/eps_prod` --ca-file $HOME/.pki/ca_prod --cert-file $HOME/.pki/cert_prod --key-file $HOME/.pki/key_prod'

alias ls='ls -G'
alias grep='grep --color=auto'
alias c='clear'
alias sed='gsed'
alias grpcurl='grpcurl -plaintext'
# alias dkb='sudo kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/'
# alias ekb='sudo kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/'

kafka-topic-describe() {
    kafka-topics --bootstrap-server $1 --describe --topic $2
}

kafka-topic-consume() {
    kt consume -brokers $1 -topic $2
}

getip() {
    dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"'
}

gitsetzero() {
    git init
    git config --local --add user.email morgoevm@gmail.com
    git config --local --add user.name zerospiel
}

getgot() {
    go get github.com/melbahja/got/cmd/got
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
    got -o $GOBIN/buf https://github.com/bufbuild/buf/releases/download/$v/buf-`uname -s`-`uname -m`
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
