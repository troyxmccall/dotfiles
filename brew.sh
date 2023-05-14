#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

#homebrew now includes cask, so let's get rid of the old version
brew uninstall --force brew-cask

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# make sure we can use our launch agents
mkdir -p ~/Library/LaunchAgents

# autoupdate - https://github.com/Homebrew/homebrew-autoupdate
brew tap homebrew/autoupdate
brew autoupdate start


# Uninstall ALL php related Packages (most of them homebrew/php related)
brew list | grep php | xargs brew uninstall --force
# Clean cache
brew cleanup
# Ensure latest brew repo HEAD
brew update
# Install latest php
brew install php
pecl install xdebug

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils


# SIP blocks this symbolic link - let's trust apple for now

#ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"


# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install Bash 4.
# Note: don’t forget to add `$(brew --prefix)/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew install bash-completion
# we like colors
brew install grc

# Switch to using brew-installed bash as default shell
if ! fgrep -q "$(brew --prefix)/bin/bash" /etc/shells; then
  echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells;
  chsh -s $(brew --prefix)/bin/bash;
fi;

brew install curl

# Install `wget`
brew install wget

# Install more recent versions of some OS X tools.
brew install vim
brew install grep
brew install openssh
brew install screen

# other utils
brew install tmux
brew install gnutls

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

#tap services - see: https://github.com/Homebrew/homebrew-services
brew tap homebrew/services

#install older verion of php
brew install php
brew install brew-php-switcher


#mariadb
brew install mariadb

#install php mods / composer
brew install composer
brew install phpmd
brew install php-code-sniffer
brew install php-cs-fixer

#install some http benchmarking tools
brew install wrk
brew install siege
brew install vegeta
#install some other http tools
brew install httpie

#install some network benchmarking/testing tools
brew install iperf3
brew install nuttcp
brew install mtr
brew install owamp
brew install scamper
brew install whatmask
brew install testssl

#ssh stuff
brew install ssh-copy-id
brew install stormssh

# dev env deps
brew install dnsmasq
brew install mkcert


# Install other useful binaries.
brew install ack
brew install autojump
brew install bat
brew install ccat
brew install dark-mode
brew install diff-so-fancy
brew install exiv2
brew install fzf
brew install gh
brew install git
brew install git-lfs
brew install glances
brew install graphicsmagick
brew install hub
brew install htop
brew install imagemagick
brew install jq
brew install lnav
brew install lua
brew install lynx
brew install ngrep
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rhino
brew install speedtest_cli
brew install the_silver_searcher
brew install tree
brew install trash
brew install unzip
brew install webkit2png
brew install youtube-dl
brew install zopfli
brew install z

# even more additional utils, only listed here bc i added them so much later
# brew install android-platform-tools

# Install Node Version Manager - because we are going to need to run multiple versions of node
brew install nvm
# install phantomjs for el capitan
# brew install phantomjs
# brew link --overwrite phantomjs

#install rbenv and ruby build
brew install rbenv
brew install ruby-build
brew install rbenv-default-gems

#use brewed git
brew link git --overwrite

#config git
curl -s -O \
https://github-media-downloads.s3.amazonaws.com/osx/git-credential-osxkeychain

chmod u+x git-credential-osxkeychain

sudo mv git-credential-osxkeychain "$(dirname $(which git))/git-credential-osxkeychain"

git config --global credential.helper osxkeychain

#dat private repo access
pub=$HOME/.ssh/id_rsa.pub
echo 'Checking for SSH key, generating one if it does not exist...'
if
  [ ! -f $pub ] ; then
  ssh-keygen -t rsa
  echo 'Copying public key to clipboard. Paste it into your Github account...'
  cat $pub | pbcopy
  open 'https://github.com/account/ssh'
fi

#import anti-gravity
brew install python
brew linkapps python
pip install Pygments
pip install requests
brew install pyenv
brew install pyenv-virtualenv


#gowithit
brew install go
brew install goenv

#java
brew install jenv

#mopidy
# brew tap mopidy/mopidy
# brew install mopidy
# brew install mopidy-spotify

#thefuck: https://github.com/nvbn/thefuck
brew install thefuck

#vm builder tools
# brew install packer
# brew install ansible

#sharp
brew install vips

#yarn - smell ya later npm
brew install yarn
brew install node
brew install yarn-completion

#docker
brew install docker
brew install docker-compose
brew install docker-credential-helper
brew install docker-buildx
# brew install docker-machine
# brew install docker-machine-nfs


# Remove outdated versions from the cellar.
brew cleanup
