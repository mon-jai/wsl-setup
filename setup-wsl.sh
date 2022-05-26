echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

sudo apt install wslu -y

WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
HOME_DICECTORY="/home/$(whoami)"

# https://askubuntu.com/a/86891
cp -vra ~/. $WINDOWS_USER_PROFILE
sudo rm -r "/home/$(whoami)"
sudo ln -s $WINDOWS_USER_PROFILE $HOME_DICECTORY
sudo chown $(whoami):$(whoami) -R $HOME_DICECTORY
