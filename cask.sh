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

#homebrew now includes cask, so let's get rid of the old version
brew uninstall --force brew-cask
brew untap phinze/cask
brew untap caskroom/cask

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

# Handle dependencies
brew tap caskroom/cask
brew tap caskroom/versions

# dependencies for Formulas and Casks
dependencies=(
  java
  java6
  virtualbox
  vmware-fusion
  xquartz
)

# Install dependencies to /Applications - default is: /Users/$user/Applications
echo "installing dependencies..."

for app in "${dependencies[@]}"
do
  brew cask install --appdir="/Applications" $app
done

# Apps for caskroom
apps=(
  adobe-creative-cloud
  airparrot
  alfred
  alternote
  appcleaner
  armitage
  atom
  backblaze
  basecamp
  betterzipql
  blockblock
  brackets
  charles
  chitchat
  cloudup
  dash
  dnscrypt
  docker
  docker-toolbox
  dropbox
  firefox
  flash
  flux
  geekbench
  geektool
  google-chrome-beta
  goofy
  hazel
  hosts
  imageoptim
  iterm2-beta
  keepingyouawake
  knockknock
  lastpass
  launchrocket
  licecap
  little-snitch
  lockdown
  malwarebytes-anti-malware
  max
  mono-mdk
  onyx
  opera
  ostiarius
  paparazzi
  paw
  postman
  provisionql
  qlcolorcode
  qlimagesize
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-json
  quicklook-csv
  screenflick
  sequel-pro
  shiori
  shuttle
  sketch
  skype
  slack
  spectacle
  spotify
  sonarr
  sublime-text
  suspicious-package
  telegram
  torbrowser
  tower
  transmission
  transmit
  vagrant
  viscosity
  vlc
  vox
  vox-preferences-pane
  webpquicklook
  wireshark
  yakyak
)

# Install apps to /Applications - default is: /Users/$user/Applications
echo "installing cask apps..."

for app in "${apps[@]}"
do
  brew cask install --appdir="/Applications" $app --force
done

brew cask cleanup
