
# profile

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

export PATH=$PATH:$GOBIN
export LC_ALL='en_US.UTF-8'
export PS1="\[\033[38;5;5m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;10m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\] \[\033[38;5;14m\]\$(get_branch)\[$(tput sgr0)\]"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export BASH_SILENCE_DEPRECATION_WARNING=1

alias k="kubectl"
alias fixgovno='launchctl unload /Library/LaunchAgents/com.trusourcelabs.NoMAD.plist; killall NoMAD'
alias etcdctl2='ETCDCTL_API=2 etcdctl'
alias etcdstg='etcdctl2 --endpoints `cat $HOME/.pki/eps_stg` --ca-file $HOME/.pki/ca_stg --cert-file $HOME/.pki/cert_stg --key-file $HOME/.pki/key_stg'
alias etcdprod='etcdctl2 --endpoints `cat $HOME/.pki/eps_prod` --ca-file $HOME/.pki/ca_prod --cert-file $HOME/.pki/cert_prod --key-file $HOME/.pki/key_prod'

# warden related cmds
# warden related cmds

alias ls='ls -G'
alias grep='grep --color=auto'
alias c='clear'

kafka-topic-describe() {
    kafka-topics --bootstrap-server $1 --describe --topic $2
}

kafka-topic-consume() {
    kt consume -brokers $1 -topic $2
}

get_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' | awk 'END{if ($1 != "") print($0 " ")}' | sed 's/ (/(/'
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
