sudo ln -s "$(wslpath "$(wslvar USERPROFILE)")" /
rm -rf root
mv Max root

# Setup zsh
apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "LISTMAX=-1" >> ~/.zshrc
sed -i '1s;^;ZSH_DISABLE_COMPFIX=true\n;' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Setup neovim
apt install -y neovim
NVIM_CONFIG_FOLDER=~/.config/nvim/
mkdir -p $NVIM_CONFIG_FOLDER
(cd $NVIM_CONFIG_FOLDER && curl https://raw.githubusercontent.com/vim/vim/master/runtime/mswin.vim -O)
(cd $NVIM_CONFIG_FOLDER && curl https://raw.githubusercontent.com/vim/vim/master/runtime/evim.vim -o init.vim)
echo "inoremap <c-q> <c-o>::confirm quit<cr>" >> $NVIM_CONFIG_FOLDER/init.vim
