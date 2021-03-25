#!/usr/bin/env bash
# vim: ai ts=2 sw=2 et sts=2 ft=sh

# Install or re-install phpenv with
# multiple versions of PHP on macOS.
#
# Usage:
#
#   curl -L https://git.io/JvG7i | bash
#

# Bash strict mode.
set -o pipefail
set -o errexit
set -o nounset

# Allow empty globs.
shopt -s nullglob

IFS=$' '

# Check OS.
if [[ "${OSTYPE//[0-9.]/}" != "darwin" ]]; then
  (>&2 echo "Error: This script is for macOS not '${OSTYPE}'.")
  exit 1;
fi

brew_install() {
  # Install homebrew.
  if ! command -v brew 1>/dev/null; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

php_install() {
  local PHP_VER;
  local PHP_EXT;

  # Install PHP versions.
  for PHP_VER in "7.2" "7.3" "7.4" "8.0"; do
    # Do not overwrite existing php install.
    if brew list --versions "php@${PHP_VER}" 1>/dev/null; then
      (>&2 echo "PHP ${PHP_VER} already installed.")
      # todo: backup global composer config and update php version.
      continue
    fi

    brew install "php@${PHP_VER}" || true
    echo "date.timezone = UTC" > "$(brew --prefix)/etc/php/${PHP_VER}/conf.d/date.ini"

    # Install PHP extensions.
    IFS=$' '
    for PHP_EXT in "opcache" "xdebug" "yaml"; do
      brew install "php${PHP_VER/./}-${PHP_EXT}" 2>/dev/null || true
    done;
    # Cleaning up.
    brew unlink "php@${PHP_VER}" || true
  done;
}

phpenv_install() {
  # Install phpenv.
  export PHPENV_ROOT="${HOME}/.phpenv"

  # shellcheck disable=SC2016
  if ! command -v phpenv 1>/dev/null; then
    ( curl -fsSL https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer | bash ) || true
    { echo 'export PHPENV_ROOT="${HOME}/.phpenv"'
      echo 'if [[ -d "${PHPENV_ROOT}" ]]; then'
      echo '  export PATH="${PHPENV_ROOT}/bin:${PATH}";'
      echo '  eval "$(phpenv init -)";'
      echo 'fi'
    } >> "${HOME}/.extra"

    export PATH="${PHPENV_ROOT}/bin:${PATH}"
    eval "$(phpenv init -)"
  else
    (>&2 echo "Updating phpenv.")
    phpenv update
  fi

  #install 7.1.x from source
  brew install autoconf bison bzip2 curl icu4c libedit libjpeg libiconv libpng libxml2 libzip openssl re2c tidy-html5 zlib mcrypt
  CFLAGS=-DU_DEFINE_FALSE_AND_TRUE=1 CONFIGURE_OPTS="--with-zlib-dir=$(brew --prefix zlib) --with-bz2=$(brew --prefix bzip2) --with-curl=$(brew --prefix curl) --with-iconv=$(brew --prefix libiconv) --with-libedit=$(brew --prefix libedit) --with-readline=$(brew --prefix readline) --with-tidy=$(brew --prefix tidy-html5)" phpenv install 7.1.9
}

phpenv_versions_cleanup() {
  local _shim_link;
  local _shim_realpath;

  if [[ ! -d "${HOME}/.phpenv/versions" ]]; then
    mkdir -p "${HOME}/.phpenv/versions"
  fi

  for _shim_link in "${HOME}"/.phpenv/versions/[0-9].[0-9]*/; do
    _shim_realpath="$(cd -P "$_shim_link" && pwd)"
    if [[ "$_shim_realpath" == "$(brew --cellar)"* ]]; then
      unlink "$_shim_link" 2>/dev/null || true
    fi
  done
}

phpenv_versions_rehash() {
  local _php_path;
  local _php_full_ver;
  local _php_version;

  if [[ ! -d "${HOME}/.phpenv/versions" ]]; then
    mkdir -p "${HOME}/.phpenv/versions"
  fi

  for _php_path in "$(brew --cellar)"/php*/[0-9].[0-9].*; do
    _php_full_ver="${_php_path##*/}";
    _php_version="${_php_full_ver%.*}";
    unlink "${HOME}/.phpenv/versions/${_php_version}" 2>/dev/null || true
    ln -s "${_php_path}" "${HOME}/.phpenv/versions/${_php_version}" 2>/dev/null || true
  done

  phpenv rehash
}

brew_install
php_install
phpenv_install
phpenv_versions_cleanup
phpenv_versions_rehash

