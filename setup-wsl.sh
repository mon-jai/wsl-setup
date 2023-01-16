#!/usr/bin/env bash

# https://superuser.com/a/1492456
echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

sudo apt install -y wslu
# https://superuser.com/a/1568668/1172895
WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
HOME_DICECTORY="/home/$(whoami)"

# https://askubuntu.com/a/86891
cp -vra ~/. "$WINDOWS_USER_PROFILE"
sudo rm -r "$HOME_DICECTORY"
sudo ln -s "$WINDOWS_USER_PROFILE" "$HOME_DICECTORY"
sudo chown "$(whoami):$(whoami)" -R "$HOME_DICECTORY"

sudo apt update
sudo apt install -y clang
sudo apt install -y pkg-config libssl-dev libxcb-composite0-dev libx11-dev
curl --proto https --tlsv1.2 -sSf https://sh.rustup.rs | sh -y
source "$HOME/.cargo/env"
cargo install nu --features=extra

# https://www.nushell.sh/book/installation.html#setting-the-login-shell-nix
which nu | sudo tee -a /etc/shells > '/dev/null'
# https://unix.stackexchange.com/a/111367
sudo chsh -s "$(command -v nu)" "$USER"

NU_VERSION=$(nu --version)
NU_CONFIG_DIRECTORY="$HOME/.config/nushell"
NU_CONFIG_FILE="NU_CONFIG_DIRECTORY/config.nu"
NU_ENV_FILE="NU_CONFIG_DIRECTORY/env.nu"

# https://unix.stackexchange.com/a/727932/407790
curl --location "https://github.com/nushell/nushell/archive/refs/tags/${NU_VERSION}.tar.gz" |\
  tar -xz --strip-components 5 --transform "s/default_//" -C "$NU_CONFIG_DIRECTORY" "nushell-${NU_VERSION}/crates/nu-utils/src/sample_config/"
rm --force "${NU_CONFIG_DIRECTORY}/sample_login.nu"

printf "alias git = git.exe\n"                                                >> $NU_CONFIG_FILE
printf "alias code = code-insiders\n"                                         >> $NU_CONFIG_FILE
printf "alias node = node.exe\n"                                              >> $NU_CONFIG_FILE
printf "alias docker = docker.exe\nalias docker-compose = docker-compose.exe" >> $NU_CONFIG_FILE
sed -i 's/show_banner: true/show_banner: false/' $NU_CONFIG_FILE

sed -i 's/def create_left_prompt/let home_directory_symlink_target = (wslpath (wslvar USERPROFILE) | str trim)\n\ndef create_left_prompt/' $NU_ENV_FILE
sed -i 's/$path_segment/$path_segment | str replace --string $home_directory_symlink_target "~"/' $NU_ENV_FILE

