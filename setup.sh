#!/usr/bin/env bash

brews=(
  aws-shell
  chainsawbaby/formula/bash-snippets
  coreutils
  findutils
  fontconfig --universal
  git
  git-extras
  hub
  git-lfs
  go
  htop
  httpie
  iftop
  imagemagick --with-webp
  node
  postgresql
  pgcli
  python
  python3
  thefuck
  tree
  vim --with-override-system-vi
  wget
)

casks=(
  atom
  firefox
  google-chrome
  handbrake
  licecap
  iterm2
  slack
  spotify
  vlc
  flux
)

pips=(
  pip
  glances
  ohmu
  pythonpy
)

gems=(
  bundle
)

npms=(
  n
)

git_configs=(
  "branch.autoSetupRebase always"
  "color.ui auto"
  "core.autocrlf input"
  "core.pager cat"
  "credential.helper osxkeychain"
  "merge.ff false"
  "pull.rebase true"
  "push.default simple"
  "rebase.autostash true"
  "rerere.autoUpdate true"
  "rerere.enabled true"
  "user.name Alexis Sgarbossa"
  "user.email alexis@sgarbossa.com.ar"
)

apms=(
  aligner
  aligner-scss
  atom-beautify
  atom-jade
  atom-sync
  busy-signal
  copy-path
  csslint
  dracula-syntax
  dracula-theme
  editorconfig
  emmet
  emmet-jsx-css-modules
  escape-utils
  file-icons
  fonts
  grayula-theme
  highlight-selected
  intentions
  language-arduino
  language-babel
  language-docker
  language-haml
  linter
  linter-eslint
  linter-sass-lint
  linter-ui-default
  mark
  maybs-quit
  merge-conflicts
  nord-atom-syntax
  nord-atom-ui
  pigments
  prettier-atom
  project-plus
  seti-ui
  sort-lines
  sync-settings
  trailing-spaces
  unity-ui
  seti-syntax
)


fonts=(
  font-source-code-pro
)

######################################## End of app list ########################################
set +e
set -x

function prompt {
  read -p "Hit Enter to $1 ..."
}

if test ! $(which brew); then
  prompt "Install Xcode"
  xcode-select --install

  prompt "Install Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  prompt "Update Homebrew"
  brew update
  brew upgrade
fi
brew doctor
brew tap homebrew/dupes

function install {
  cmd=$1
  shift
  for pkg in $@;
  do
    exec="$cmd $pkg"
    prompt "Execute: $exec"
    if ${exec} ; then
      echo "Installed $pkg"
    else
      echo "Failed to execute: $exec"
    fi
  done
}

prompt "Update ruby"
ruby -v
brew install gpg
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
ruby_version='2.6.0'
rvm install ${ruby_version}
rvm use ${ruby_version} --default
ruby -v
sudo gem update --system

prompt "Install packages"
brew info ${brews[@]}
install 'brew install' ${brews[@]}

prompt "Install software"
brew tap caskroom/versions
brew cask info ${casks[@]}
install 'brew cask install' ${casks[@]}

prompt "Installing secondary packages"
install 'pip install --upgrade' ${pips[@]}
install 'gem install' ${gems[@]}
install 'npm install --global' ${npms[@]}
install 'apm install' ${apms[@]}
brew tap caskroom/fonts
install 'brew cask install' ${fonts[@]}

prompt "Install Yarnpkg"
curl -o- -L https://yarnpkg.com/install.sh | bash

prompt "Install ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

prompt "Install iterm2 shell integration"
curl -L https://iterm2.com/misc/install_shell_integration_and_utilities.sh | bash
ln -s .zshrc ~/.zshrc
source ~/.zshrc

# prompt "Upgrade bash"
# brew install bash
# sudo bash -c "echo $(brew --prefix)/bin/bash >> /private/etc/shells"
# mv ~/.bash_profile ~/.bash_profile_backup
# mv ~/.bashrc ~/.bashrc_backup
# mv ~/.gitconfig ~/.gitconfig_backup
# cd; curl -#L https://github.com/barryclark/bashstrap/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,screenshot.png}
# #source ~/.bash_profile

prompt "Set git defaults"
for config in "${git_configs[@]}"
do
  git config --global ${config}
done

prompt "Install mac CLI [NOTE: Say NO to bash-completions since we have fzf]!"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/guarinogabriel/mac-cli/master/mac-cli/tools/install)"

prompt "Update packages"
pip3 install --upgrade pip setuptools wheel
mac update

prompt "Cleanup"
brew cleanup
brew cask cleanup

echo "Done!"
