
# profile

export GOPATH=$HOME/go
# NOTE: use this on macOS with brew's version if go
# export GOROOT=$(brew --prefix go@1.12)/libexec
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export GONOPROXY=*.ozon.ru
export GOPRIVATE=*.ozon.ru
export GOPROXY=https://proxy.golang.org,direct
export GONOSUMDB=$GONOPROXY
export GOSUMDB=sum.golang.org
export GO111MODULE=auto
export GOINSECURE=none

export PATH=$PATH:$GOBIN:$GOROOT/bin
export LC_ALL='en_US.UTF-8'
export PS1="\[\033[38;5;5m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;10m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\] \[\033[38;5;14m\]\$(get_branch)\[$(tput sgr0)\]"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export BASH_SILENCE_DEPRECATION_WARNING=1

alias kubedev="kubectl --kubeconfig $HOME/.kube/dev_cluster_developers --namespace bx $1 $2"
alias kubestg="kubectl --kubeconfig $HOME/.kube/stg_cluster_developers --namespace bx $1 $2"
alias kubeprod="kubectl --kubeconfig $HOME/.kube/prod_cluster_developers --namespace bx $1 $2"

alias ls='ls -G'
alias grep='grep --color=auto'
alias c='clear'

kafka-topic-describe() {
	kafka-topics --bootstrap-server $1 --describe --topic $2
}

# NOTE: kt bin is required
kafka-topic-consume() {
	kt consume -brokers $1 -topic $2
}

get_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' | awk 'END{if ($1 != "") print($0 " ")}' | sed 's/ (/(/'
}
