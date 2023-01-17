#!/usr/bin/env bash

sudo apt update

# https://superuser.com/a/1492456
echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

sudo apt install -y wslu
# https://superuser.com/a/1568668/1172895
WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
HOME_DICECTORY="/home/$(whoami)"

# https://stackoverflow.com/a/21593371/11077662
cd /
# https://askubuntu.com/a/86891
cp -vra ~/. "$WINDOWS_USER_PROFILE"
sudo rm -r "$HOME_DICECTORY"
sudo ln -s "$WINDOWS_USER_PROFILE" "$HOME_DICECTORY"
sudo chown "$(whoami):$(whoami)" -R "$HOME_DICECTORY"
# This message is shown once a day. To disable it please create the /home/max/.hushlogin file.
touch "${HOME}/.hushlogin"

# https://superuser.com/a/392878/1172895
# https://stackoverflow.com/a/21928782/11077662
ls /mnt | grep -E "^[a-z]$" | xargs -d "\n" -I {} sudo ln -s /mnt/{} /{}

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install nushell
echo "Last exit code: $?"

# https://www.nushell.sh/book/installation.html#setting-the-login-shell-nix
which nu | sudo tee -a /etc/shells > '/dev/null'
# https://unix.stackexchange.com/a/111367
sudo chsh -s "$(command -v nu)" "$USER"

NU_VERSION=$(nu --version)
NU_CONFIG_DIRECTORY="$HOME/.config/nushell"
NU_CONFIG_FILE="${NU_CONFIG_DIRECTORY}/config.nu"
NU_ENV_FILE="${NU_CONFIG_DIRECTORY}/env.nu"

# mkdir if not exists, https://stackoverflow.com/a/793867/11077662
mkdir -p "$NU_CONFIG_DIRECTORY"
# https://unix.stackexchange.com/a/727932/407790
curl -fsSL "https://github.com/nushell/nushell/archive/refs/tags/${NU_VERSION}.tar.gz" |\
# https://askubuntu.com/a/1366385/1056703
  tar -xz --touch --strip-components 5 --transform "s/default_//" -C "$NU_CONFIG_DIRECTORY" "nushell-${NU_VERSION}/crates/nu-utils/src/sample_config/"
rm --force "${NU_CONFIG_DIRECTORY}/sample_login.nu"

printf "alias git = git.exe\n"                                                >> "$NU_CONFIG_FILE"
printf "alias code = code-insiders\n"                                         >> "$NU_CONFIG_FILE"
printf "alias node = node.exe\n"                                              >> "$NU_CONFIG_FILE"
printf "alias docker = docker.exe\nalias docker-compose = docker-compose.exe" >> "$NU_CONFIG_FILE"
sed -i 's/show_banner: true/show_banner: false/'                                 "$NU_CONFIG_FILE"

sed -i 's/def create_left_prompt/let home_directory_symlink_target = (wslpath (wslvar USERPROFILE) | str trim)\n\ndef create_left_prompt/' "$NU_ENV_FILE"
sed -i 's/$path_segment/$path_segment | str replace --string $home_directory_symlink_target "~"/'                                          "$NU_ENV_FILE"
