echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

sudo apt install wslu -y

WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
HOME_DICECTORY="/home/$(whoami)"

# https://askubuntu.com/a/86891
cp -vra ~/. $WINDOWS_USER_PROFILE
sudo rm -r $HOME_DICECTORY
sudo ln -s $WINDOWS_USER_PROFILE $HOME_DICECTORY
sudo chown $(whoami):$(whoami) -R $HOME_DICECTORY

sudo apt install -y clang
sudo apt install -y pkg-config libssl-dev libxcb-composite0-dev libx11-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
cargo install nu --features=extra

# https://www.nushell.sh/book/installation.html#setting-the-login-shell-nix
echo $(which nu) | sudo tee -a /etc/shells > '/dev/null'
# https://unix.stackexchange.com/a/111367
sudo chsh -s "$(command -v nu)" "${USER}"

printf "alias npm = npm.exe\nalias npx = npx.exe\nalias node = node.exe\n" >> ~/.config/nushell/config.nu