apt install -y neovim zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
echo "alias -g ~=\"/mnt/c/Users/Max\"\n" >> ~/.zshrc
echo "LISTMAX=-1\n" >> ~/.zshrc

# Setup neovim
NVIM_CONFIG_FOLDER=~/.config/nvim/
mkdir -p $NVIM_CONFIG_FOLDER
(cd $NVIM_CONFIG_FOLDER && curl https://raw.githubusercontent.com/vim/vim/master/runtime/mswin.vim -O)
(cd $NVIM_CONFIG_FOLDER && curl https://raw.githubusercontent.com/vim/vim/master/runtime/evim.vim -o init.vim)
echo "inoremap <c-q> <c-o>::confirm quit<cr>" >> $NVIM_CONFIG_FOLDER/init.vim
