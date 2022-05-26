echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

sudo apt install wslu -y

WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
# https://askubuntu.com/a/86891
cp -vra ~/. $WINDOWS_USER_PROFILE
rm -rf ~
ln -s WINDOWS_USER_PROFILE ~
