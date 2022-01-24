#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install some more CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install cowpatty
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install mitmproxy
brew install pngcheck
brew install reaver
brew install snort
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install tcpdump
brew install trafshow
brew install dhcpdump
brew install ucspi-tcp # `tcpserver` etc.
brew install whois
brew install wireshark
brew install xpdf
brew install xz

# Remove outdated versions from the cellar.
brew cleanup
