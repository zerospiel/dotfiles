# VS Code

Refers to a VS Code specific path (i.e. '~/Library/Application\ Support/Code/User/settings.json')

> NOTE: dump extensions

```shell
rm $(pwd)/vscode/extensions.bash && \
    echo -e '#!/usr/bin/env bash\n' > $(pwd)/vscode/extensions.bash && \
    code --list-extensions | xargs -n1 echo 'code --install-extension' >> $(pwd)/vscode/extensions.bash
```
