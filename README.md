# Troy’s dotfiles
![Screenshot of my shell prompt](http://i.imgur.com/2ADOkhf.png)

## Installation
**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don't want or need. Don't blindly use my settings unless you know what that entails. Use at your own risk!

### Using Git and the bootstrap script
You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```bash
git clone https://github.com/troyxmccall/dotfiles.git && cd dotfiles && bash bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```


To update later on, just run that command again.

### Specify the `$PATH`
If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as [detecting which version of `ls` is being used](https://github.com/troyxmccall/dotfiles/blob/aff769fd75225d8f2e481185a71d5e05b76002dc/.aliases#L21-26)) takes place.

Here's an example `~/.path` file that adds `$(brew --prefix)/bin` to the `$PATH`:

```bash
export PATH="$(brew --prefix)/bin:$PATH"
```

### Add custom commands without creating a new fork
If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don't want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Troy McCall"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="troyxmccall@github.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"

#personal globals
export COMPOSER_AUTH=$(jq -c . < ~/.composer/auth.json)
#command line alias for opening projects with `e .`
export PROJECT_EDITOR=phpstorm
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It's probably better to [fork this repository](https://github.com/mathiasbynens/dotfiles/fork) instead, though.

### Sensible OS X defaults
When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./.macos
```

### Install Homebrew formulas
When setting up a new Mac, you may want to install some common [Homebrew](http://brew.sh/) formulae (after installing Homebrew, of course):

```bash
./brew.sh
```

### Install Brew Casks
because downloading binaries is so 2009:

```bash
./cask.sh
```

### Install Node Modules
the world runs on node

```bash
./npm.sh
```



## Feedback
Suggestions/improvements [welcome](https://github.com/troyxmccall/dotfiles/issues)!

## Author

| [![twitter/interzonejunkie](https://avatars0.githubusercontent.com/u/129784?v=3&s=70)](http://twitter.com/interzonejunkie "Follow @interzonejunkie on Twitter")
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------
| [Troy McCall](http://thoughtalotaboutbeingarobot.net)

## Thanks to…

| [![twitter/mathias](http://gravatar.com/avatar/24e08a9ea84deb17ae121074d0f17125?s=70)](http://twitter.com/mathias "Follow @mathias on Twitter")
| -----------------------------------------------------------------------------------------------------------------------------------------------
| [Mathias Bynens](https://mathiasbynens.be/)

- @ptb and [his _OS X Lion Setup_ repository](https://github.com/ptb/Mac-OS-X-Lion-Setup)
- [Ben Alman](http://benalman.com/) and his [dotfiles repository](https://github.com/cowboy/dotfiles)
- [Chris Gerke](http://www.randomsquared.com/) and his [tutorial on creating an OS X SOE master image](http://chris-gerke.blogspot.com/2012/04/mac-osx-soe-master-image-day-7.html) + [_Insta_ repository](https://github.com/cgerke/Insta)
- [Cătălin Mariș](https://github.com/alrra) and his [dotfiles repository](https://github.com/alrra/dotfiles)
- [Gianni Chiappetta](http://gf3.ca/) for sharing his [amazing collection of dotfiles](https://github.com/gf3/dotfiles)
- [Jan Moesen](http://jan.moesen.nu/) and his [ancient `.bash_profile`](https://gist.github.com/1156154) + [shiny _tilde_ repository](https://github.com/janmoesen/tilde)
- [Lauri 'Lri' Ranta](http://lri.me/) for sharing [loads of hidden preferences](http://osxnotes.net/defaults.html)
- [Matijs Brinkhuis](http://hotfusion.nl/) and his [dotfiles repository](https://github.com/matijs/dotfiles)
- [Nicolas Gallagher](http://nicolasgallagher.com/) and his [dotfiles repository](https://github.com/necolas/dotfiles)
- [Sindre Sorhus](http://sindresorhus.com/)
- [Tom Ryder](http://blog.sanctum.geek.nz/) and his [dotfiles repository](https://github.com/tejr/dotfiles)
- [Kevin Suttle](http://kevinsuttle.com/) and his [dotfiles repository](https://github.com/kevinSuttle/dotfiles) and [OSXDefaults project](https://github.com/kevinSuttle/OSXDefaults), which aims to provide better documentation for [`~/.macos`](https://mths.be/osx)
- [Haralan Dobrev](http://hkdobrev.com/)
- anyone who [contributed a patch](https://github.com/mathiasbynens/dotfiles/contributors) or [made a helpful suggestion](https://github.com/mathiasbynens/dotfiles/issues)
