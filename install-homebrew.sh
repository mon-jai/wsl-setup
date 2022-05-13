/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | sed 's/\[\[ "\${EUID:-\${UID}}" == "0" ]]/false/' | sed 's/HOMEBREW_PREFIX_DEFAULT="\/home\/linuxbrew\/\.linuxbrew"/HOMEBREW_PREFIX_DEFAULT="\${HOME}\/.linuxbrew"/')"
sed -i 's/\[\[ "$(id -u)" == 0 ]] || //' /root/.linuxbrew/Homebrew/Library/Homebrew/brew.sh
