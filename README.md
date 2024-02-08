# WSL Setup

```sh
# https://superuser.com/a/1732998/
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mon-jai/wsl-setup/main/setup-wsl.sh)"
```
