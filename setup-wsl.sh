#!/usr/bin/env bash

sudo apt update

# https://superuser.com/a/1492456
echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo dd of="/etc/sudoers.d/$(whoami)"

sudo apt install -y wslu
# https://superuser.com/a/1568668/1172895
WINDOWS_USER_PROFILE="$(wslpath "$(wslvar USERPROFILE)")"
HOME_DICECTORY="/home/$(whoami)"

# https://stackoverflow.com/a/21593371
cd /
# https://askubuntu.com/a/86891
cp -vra ~/. "$WINDOWS_USER_PROFILE"
sudo rm -r "$HOME_DICECTORY"
sudo ln -s "$WINDOWS_USER_PROFILE" "$HOME_DICECTORY"
sudo chown "$(whoami):$(whoami)" -R "$HOME_DICECTORY"
# This message is shown once a day. To disable it please create the /home/max/.hushlogin file.
touch "${HOME}/.hushlogin"

# https://superuser.com/a/392878/1172895
# https://stackoverflow.com/a/21928782
ls /mnt | grep -E "^[a-z]$" | xargs -d "\n" -I {} sudo ln -s /mnt/{} /{}

HOMEBREW_INSTALL_FROM_API=1 NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install nushell

# https://www.nushell.sh/book/installation.html#setting-the-login-shell-nix
which nu | sudo tee -a /etc/shells > '/dev/null'
# https://unix.stackexchange.com/a/111367
sudo chsh -s "$(command -v nu)" "$USER"

NU_VERSION=$(nu --version)
NU_CONFIG_DIRECTORY="$HOME/.config/nushell"
NU_ENV_FILE="${NU_CONFIG_DIRECTORY}/env.nu"
NU_CONFIG_FILE="${NU_CONFIG_DIRECTORY}/config.nu"

# mkdir if not exists, https://stackoverflow.com/a/793867
mkdir -p "$NU_CONFIG_DIRECTORY"
# https://unix.stackexchange.com/a/727932/407790
# https://askubuntu.com/a/1366385/1056703
curl -fsSL "https://github.com/nushell/nushell/archive/refs/tags/${NU_VERSION}.tar.gz" |\
tar -xz --touch --strip-components 5 --transform "s/default_//" -C "$NU_CONFIG_DIRECTORY" "nushell-${NU_VERSION}/crates/nu-utils/src/sample_config/"
rm --force "${NU_CONFIG_DIRECTORY}/sample_login.nu"

# https://askubuntu.com/a/533268
# https://stackoverflow.com/a/13279193
perl -i -0pe "s/def create_left_prompt.*def create_right_prompt/\
def create_left_prompt [] {
  let ansi_prefix = if (is-admin) { (ansi red_bold) } else { (ansi green_bold) }
  let path = (
    \\\$env.PWD
    | str replace --string (wslpath (wslvar USERPROFILE) | str trim) \"~\"
    | str replace \"^\/mnt\" \"\"
    | str replace -a \"\/\" \" \/ \"
    | str trim
  )
  \\\$ansi_prefix + \\\$path
}

def create_right_prompt/s" $NU_ENV_FILE

printf '
let-env LINUX_BINS = (ls /usr/bin/ --short-names | get name | str join ";") + ";"

powershell.exe -Command "& { Get-Command -Type Application | ForEach-Object { $_.Name } }" | lines
| filter {|| "." in $in and " " not-in $in }
| reduce --fold "" {|executable, acc| (
  let split_results     = ($executable | split row ".");
  let command_name      = $split_results.0;
  let extension         = $split_results.1;
  let alias_declaration = $"alias ($command_name) = ";
  let command_prefix    = (
    if $extension == "cmd" or $extension == "bat" { "cmd.exe /c " }
    else if $extension == "ps1" { "powershell.exe " }
    else { "" }
  );

  if (not $alias_declaration in $acc) and (not $command_name + ";" in $env.LINUX_BINS) {
    $acc + $"($alias_declaration)($command_prefix)($executable)\\n"
  } else {
    $acc
  }
)}
| save --force ~/.config/nushell/env-generated.nu

hide-env LINUX_BINS
\n' >> $NU_ENV_FILE

sed -i 's/let-env PROMPT_INDICATOR = { "\(.\) " }/let-env PROMPT_INDICATOR = { " \1 " }/' $NU_ENV_FILE
printf "let-env PATH = (bash -c \$\"(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\\\\necho \$PATH;\")\n" >> $NU_ENV_FILE

printf "alias code = code-insiders\n"                >> $NU_CONFIG_FILE
printf "source ~/.config/nushell/env-generated.nu\n" >> $NU_CONFIG_FILE
sed -i 's/show_banner: true/show_banner: false/'        $NU_CONFIG_FILE

history -c
