cd $HOME
if [ -d brew-install ]; then
  echo "$HOME/brew-install folder is found. Let's clean it first."
  rm -rf brew-install
fi

### Download the install script first - https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install

### Search and update following 2 variables
# HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
# HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git”
sed -i '' 's|HOMEBREW_BREW_GIT_REMOTE=.*$|HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"|g' brew-install/install.sh
sed -i '' 's|HOMEBREW_CORE_GIT_REMOTE=.*$|HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"|g' brew-install/install.sh

### Run install.sh
bash brew-install/install.sh

### Then
if [ -f $HOME/.zprofile ]; then
  if [ "" = "$(grep 'eval $(/opt/homebrew/bin/brew shellenv)' $HOME/.zprofile)" ]; then
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> $HOME/.zprofile
  fi
fi
if [ -f $HOME/.bash_profile ]; then
  if [ "" = "$(grep 'eval $(/opt/homebrew/bin/brew shellenv)' $HOME/.bash_profile)" ]; then
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> $HOME/.bash_profile
  fi
fi
eval $(/opt/homebrew/bin/brew shellenv)

### Following commands are recommended by https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
grep -qF '/opt/homebrew/bin' /etc/paths || sudo sed -i "" '1i \
/opt/homebrew/bin
' /etc/paths
grep -qF '/opt/homebrew/share/man' /etc/manpaths || sudo sed -i "" '1i \
/opt/homebrew/share/man
' /etc/manpaths 

### Update repo
git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git

git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
git -C "$(brew --repo homebrew/cask-fonts)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
git -C "$(brew --repo homebrew/cask-drivers)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git
git -C "$(brew --repo homebrew/cask-versions)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-versions.git

brew update-reset

### Do not use Tsinghua's bottles service as it always complains SHA256 mismatch.
<<COMMENT
### Update bottles - https://mirrors.tuna.tsinghua.edu.cn/help/homebrew-bottles/
#### Bash
if [ -f $HOME/.bash_profile ]; then
  if [ "" = "$(grep 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' $HOME/.bash_profile)" ]; then
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.bash_profile
  fi
  source ~/.bash_profile
fi
#### Zsh
if [ -f $HOME/.zprofile ]; then
  if [ "" = "$(grep 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' $HOME/.zprofile)" ]; then
    echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.zprofile
  fi
  source ~/.zprofile
fi
COMMENT

cd -
