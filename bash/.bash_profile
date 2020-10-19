#bash profile

if [ -f $HOME/.profile ]; then
    . $HOME/.profile
fi

# macOS brew's bash setting
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
