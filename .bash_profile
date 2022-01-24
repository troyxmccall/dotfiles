#!/usr/bin/env bash

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;


# Homebrew for M1s
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

#alias hub as git https://github.com/github/hub#aliasing
if which hub > /dev/null; then eval "$(hub alias -s)"; fi
#iterm2 shell integration https://iterm2.com/shell_integration.html
test -e ${HOME}/.iterm2_shell_integration.bash && source ${HOME}/.iterm2_shell_integration.bash
# https://github.com/rupa/z
if [ -f `brew --prefix`/etc/profile.d/z.sh ]; then
  . `brew --prefix`/etc/profile.d/z.sh
fi
#wakatime
if [ -f $HOME/projects/bash-wakatime/bash-wakatime.sh ]; then
  . $HOME/projects/bash-wakatime/bash-wakatime.sh
fi

### ALL THE LANG ENVS

#nvm because node is just as fucked as ruby
if [ -f "$(brew --prefix nvm)/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  . "$(brew --prefix nvm)/nvm.sh"
  [[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion
  #alias builtin cd function to call nvm_auto_switch everytime
  function cd() { builtin cd "$@"; nvm_auto_switch; }
fi

#swift env
if which swiftenv > /dev/null; then eval "$(swiftenv init -)"; fi
#pyenv
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init --path)"; fi
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

#pyenv virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
#jenv
if which jenv > /dev/null; then eval "$(jenv init -)"; fi
#rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

#### END LANG ENV

#starship
if which starship > /dev/null; then eval "$(starship init bash)"; fi
#bash completion for docker-machine-pf
complete -W "start stop view" docker-machine-pf

#aritsan completion
complete -F _artisan art
complete -F _artisan artisan

#let's override __git_refs from /usr/local/etc/bash_completion.d/git-completion.bash
# this override removes tags from tab completion for git checkout, so it's just remotes and locals
# we want this to load at the very end after all functions/bash_completion so it's the final override. hence it's place in this file vs functions
__git_refs ()
{
  local i hash dir track="${2-}"
  local list_refs_from=path remote="${1-}"
  local format refs
  local pfx="${3-}" cur_="${4-$cur}" sfx="${5-}"
  local match="${4-}"
  local fer_pfx="${pfx//\%/%%}" # "escape" for-each-ref format specifiers

  __git_find_repo_path
  dir="$__git_repo_path"

  if [ -z "$remote" ]; then
    if [ -z "$dir" ]; then
      return
    fi
  else
    if __git_is_configured_remote "$remote"; then
      # configured remote takes precedence over a
      # local directory with the same name
      list_refs_from=remote
    elif [ -d "$remote/.git" ]; then
      dir="$remote/.git"
    elif [ -d "$remote" ]; then
      dir="$remote"
    else
      list_refs_from=url
    fi
  fi

  if [ "$list_refs_from" = path ]; then
    if [[ "$cur_" == ^* ]]; then
      pfx="$pfx^"
      fer_pfx="$fer_pfx^"
      cur_=${cur_#^}
      match=${match#^}
    fi
    case "$cur_" in
    refs|refs/*)
      format="refname"
      refs=("$match*" "$match*/**")
      track=""
      ;;
    *)
      for i in HEAD FETCH_HEAD ORIG_HEAD MERGE_HEAD REBASE_HEAD; do
        case "$i" in
        $match*)
          if [ -e "$dir/$i" ]; then
            echo "$pfx$i$sfx"
          fi
          ;;
        esac
      done
      format="refname:strip=2"
      refs=("refs/heads/$match*" "refs/heads/$match*/**"
        "refs/remotes/$match*" "refs/remotes/$match*/**")
      ;;
    esac
    __git_dir="$dir" __git for-each-ref --format="$fer_pfx%($format)$sfx" \
      "${refs[@]}"
    if [ -n "$track" ]; then
      __git_dwim_remote_heads "$pfx" "$match" "$sfx"
    fi
    return
  fi
  case "$cur_" in
  refs|refs/*)
    __git ls-remote "$remote" "$match*" | \
    while read -r hash i; do
      case "$i" in
      *^{}) ;;
      *) echo "$pfx$i$sfx" ;;
      esac
    done
    ;;
  *)
    if [ "$list_refs_from" = remote ]; then
      case "HEAD" in
      $match*)  echo "${pfx}HEAD$sfx" ;;
      esac
      __git for-each-ref --format="$fer_pfx%(refname:strip=3)$sfx" \
        "refs/remotes/$remote/$match*" \
        "refs/remotes/$remote/$match*/**"
    else
      local query_symref
      case "HEAD" in
      $match*)  query_symref="HEAD" ;;
      esac
      __git ls-remote "$remote" $query_symref \
        "refs/tags/$match*" "refs/heads/$match*" \
        "refs/remotes/$match*" |
      while read -r hash i; do
        case "$i" in
        *^{}) ;;
        refs/*) echo "$pfx${i#refs/*/}$sfx" ;;
        *)  echo "$pfx$i$sfx" ;;  # symbolic refs
        esac
      done
    fi
    ;;
  esac
}

