#bash profile

if [ -f $HOME/.profile ]; then
    . $HOME/.profile
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
