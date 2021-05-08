#!/usr/bin/env bash

#install binaries using homebrewcask

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

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Handle dependencies
brew tap buo/cask-upgrade

# dependencies for Formulas and Casks
dependencies=(
  java
  java6
  java8
  virtualbox
  vmware-fusion
  xquartz
)

# if you're running a brand-spanking OS 10.13 (High Sierra) virtualbox cask installation will fail - so install it manually first, see: http://matthewpalmer.net/blog/2017/12/10/install-virtualbox-mac-high-sierra/index.html

# Install dependencies to /Applications - default is: /Users/$user/Applications
echo "installing dependencies..."

for app in "${dependencies[@]}"
do
  brew install $app --cask
done

# Apps for caskroom
apps=(
  1password
  adobe-creative-cloud
  airserver
  alfred
  appcleaner
  atom
  backblaze
  basecamp
  blockblock
  charles
  dhs
  dnscrypt
  docker
  docker-toolbox
  dropbox
  evernote
  firefox
  firefox-developer-edition
  gitkraken
  geekbench
  google-chrome
  handbrake
  harvest
  hazel
  imageoptim
  iterm2
  jetbrains-toolbox
  keepingyouawake
  knockknock
  ksdiff
  launchrocket
  licecap
  lulu
  max
  onyx
  paparazzi
  postman
  private-internet-access
  provisionql
  qlcolorcode
  qlimagesize
  qlmarkdown
  qlprettypatch
  qlstephen
  qlvideo
  quicklookase
  quicklook-json
  quicklook-csv
  screenflick
  rectangle
  setapp
  sequel-ace
  signal
  sketch
  skype
  slack
  spotify
  sublime-text
  surge
  suspicious-package
  telegram
  tor-browser
  transmission
  transmit
  typora
  vagrant
  viscosity
  vlc
  webpquicklook
  whatsapp
  wireshark
)

# Install apps to /Applications - default is: /Users/$user/Applications
echo "installing cask apps..."

for app in "${apps[@]}"
do
  brew install $app --cask
done

brew cleanup
