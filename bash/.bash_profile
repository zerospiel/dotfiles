#bash profile

if [ -f $HOME/.profile ]; then
    . $HOME/.profile
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

if [ -f $HOME/.completions/kubectl ] ; then
    . $HOME/.completions/kubectl 
    complete -F __start_kubectl k
fi

if [ -f $HOME/.completions/kubebuilder ] ; then
    . $HOME/.completions/kubebuilder
fi

[[ $- == *i* ]] && stty -ixon
