#!/usr/bin/env bash

nvm install stable
nvm install lts/boron
nvm install lts/carbon

# front-end web, client and tasks modules
npm install -g bower
npm install -g grunt-cli grunt
npm install -g gulp-cli gulp
npm install -g lodash
npm install -g forever
npm install -g browserify
# frameworks
npm install -g socket.io
npm install -g express
npm install -g mocha
npm install -g angular
#libraries
npm install -g underscore
npm install -g moment
npm install -g q
npm install -g passport
#packages
npm install -g coffee-script
# hubot
npm install -g yo generator-hubot
# other utilities
npm install -g debug
npm install -g jshint
npm install -g npm-install-missing
npm install -g webtorrent
npm install -g vtop
