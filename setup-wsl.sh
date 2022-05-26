echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

# https://askubuntu.com/a/86891
WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
cp -vra ~/. $WINDOWS_USER_PROFILE
rm -rf ~
ln -s WINDOWS_USER_PROFILE ~
