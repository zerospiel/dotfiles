
# profile

# golang related envs
export GOPATH=$HOME/go
# export GOROOT=$(brew --prefix go@1.12)/libexec
# export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export GONOPROXY=$GOPRIVATE
export GOPRIVATE=gerrit.mcp.mirantis.com,github.com/Mirantis
export GOPROXY="https://artifactory.mcp.mirantis.net/artifactory/api/go/go|https://proxy.golang.org|direct"
export GONOSUMDB=$GOPRIVATE
export GOSUMDB=sum.golang.org
export GO111MODULE=on
export GOINSECURE=none
export GOVULNDB=https://vuln.go.dev

# csharp related envs
DOTNET_CLI_TELEMETRY_OPTOUT=0

# other related envs
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$GOBIN${PATH:+:${PATH}}"
export LC_ALL='en_US.UTF-8'
export LC_TIME='en_US.UTF-8'
export PS1="\[\033[38;5;5m\]\W\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;10m\]\\$\[$(tput sgr0)\]\[\033[38;5;15m\]\[$(tput sgr0)\] \[\033[38;5;14m\]\$(get_branch)\[$(tput sgr0)\]"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad
export BASH_SILENCE_DEPRECATION_WARNING=1
# export GITLAB_TOKEN=
export KIND_EXPERIMENTAL_PROVIDER=podman

# history size
export HISTFILESIZE=1000000
export HISTSIZE=1000000

alias k="kubectl"
alias ls='ls -G'
alias grep='grep --color=auto'
alias c='clear'
alias sed='gsed'
alias grpcurl='grpcurl -plaintext'
alias ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias switcharm="arch -arm64 bash"
alias switchamd="arch -x86_64 bash"

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
    version_string="latest version"
    if [[ $argl -eq 0 ]];
    then
        v=$(git ls-remote --tags --sort v:refname --exit-code --refs https://github.com/bufbuild/buf | tail -n1 | cut -d '/' -f3 | cut -c2-)
    else
        v="$1"
        version_string="given version"
    fi
    link="https://github.com/bufbuild/buf/releases/download/v${v}/buf-$(uname -s)-$(uname -m)"
    curl -sI --fail -o /dev/null ${link}
    if [[ $? -ne 0 ]]; then echo "No such version ${v}" && return 1; fi
    bufpath=$(which buf)
    if [[ -e "${bufpath}" && -x "${bufpath}" ]]; then
        if [[ $(${bufpath} --version) == ${v} ]]; then echo "Current version ${v} equals to the ${version_string}" && return 0; fi
        rm ${bufpath}
    elif [[ -z ${bufpath} ]]; then bufpath=${GOBIN}/buf; fi
    echo "Getting the ${version_string}: ${v}"
    curl -sSL -o ${bufpath} https://github.com/bufbuild/buf/releases/download/v${v}/buf-`uname -s`-`uname -m` && chmod +x ${bufpath}
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

connect_ui() {
	local ssh_key=${1}
	local user=${2}
	local private_ip=${3}
	local public_ip=${4}
	ssh -i ${ssh_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${user}@${private_ip} -o "proxycommand ssh -W %h:%p -i ${ssh_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${user}@${public_ip}"
}

connect_seed_tmux() {
	local ssh_key=${1}
	local user_host=${2}
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${ssh_key} -t ${user_host} 'tmux a || tmux'
}

portforward_seed() {
	local ssh_key=${1}
	local user_host=${2}
	ssh -i ${ssh_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -L 127.0.0.1:9000:127.0.0.1:80 ${user_host}
}
