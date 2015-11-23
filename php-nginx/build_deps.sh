#!/bin/bash

# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# A shell script for installing PHP and nginx.
set -xe

# Tools needed for building from source.
BUILD_TOOLS=" \
    autoconf \
    bison \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    patch \
    pkg-config \
    re2c \
    binutils \
  "

# Headers files etc for libraries we build against
BUILD_DEPS=" \
    libbz2-dev \
    libcurl4-openssl-dev \
    libgettextpo-dev \
    libicu-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpcre3-dev \
    libpng-dev \
    libpq-dev \
    libreadline6-dev \
    librecode-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
  "

# Remove existing OpenSSL (could break nginx?)

OPENSSL_DIR=/usr

function build_openssl {
  # Build OpenSSL
  curl -SL "http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" -o openssl.tar.gz
  mkdir -p /usr/src/openssl
  tar -zxf openssl.tar.gz -C /usr/src/openssl --strip-components=1

  pushd /usr/src/openssl

  patch -p1 < /tmp/openssl-version-script.patch

  ./Configure \
      --prefix=$OPENSSL_DIR \
      --openssldir=/usr/lib/ssl \
      --libdir=lib/x86_64-linux-gnu \
      shared \
      no-idea \
      no-mdc2 \
      no-rc5 \
      zlib  \
      enable-tlsext \
      no-ssl2 \
      linux-x86_64
  make depend
  make
  make install
  popd
  rm -rf /usr/src/openssl
}

# Build NGINX
function build_nginx {
  curl -SL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" -o nginx.tar.gz
  curl -SL "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc" -o nginx.tar.gz.asc
  gpg --verify nginx.tar.gz.asc
  mkdir -p /usr/src/nginx
  tar -zxf nginx.tar.gz -C /usr/src/nginx --strip-components=1
  rm nginx.tar.gz
  rm nginx.tar.gz.asc

  pushd /usr/src/nginx
  ./configure \
      --prefix=$NGINX_DIR \
      --error-log-path=$LOG_DIR/nginx-error.log \
      --http-log-path=$LOG_DIR/nginx-access.log \
      --user=www-data \
      --group=www-data \
      --with-http_gzip_static_module \
      --with-pcre \
      --with-openssl=$OPENSSL_DIR

  make
  make install
  popd
  rm -rf /usr/src/nginx
}

# Build PHP
function build_php56 {
  curl -SL "http://php.net/get/php-$PHP56_VERSION.tar.gz/from/this/mirror" -o php.tar.gz
  curl -SL "http://us2.php.net/get/php-$PHP56_VERSION.tar.gz.asc/from/this/mirror" -o php.tar.gz.asc
  gpg --verify php.tar.gz.asc
  mkdir -p /usr/src/php
  tar -zxf php.tar.gz -C /usr/src/php --strip-components=1
  rm php.tar.gz
  rm php.tar.gz.asc

  mkdir -p /usr/src/php/ext/memcache
  curl -SL "http://pecl.php.net/get/memcache" -o memcache.tar.gz
  tar -zxf memcache.tar.gz -C /usr/src/php/ext/memcache --strip-components=1
  rm memcache.tar.gz

  mkdir -p /usr/src/php/ext/memcached
  curl -SL "http://pecl.php.net/get/memcached" -o memcached.tar.gz
  tar -zxf memcached.tar.gz -C /usr/src/php/ext/memcached --strip-components=1
  rm memcached.tar.gz

  rm -rf /usr/src/php/ext/json
  mkdir -p /usr/src/php/ext/json
  curl -SL "https://pecl.php.net/get/jsonc" -o jsonc.tar.gz
  tar -zxf jsonc.tar.gz -C /usr/src/php/ext/json --strip-components=1
  rm jsonc.tar.gz

  mkdir -p /usr/src/php/ext/mailparse
  curl -SL "https://pecl.php.net/get/mailparse" -o mailparse.tar.gz
  tar -zxf mailparse.tar.gz -C /usr/src/php/ext/mailparse --strip-components=1
  rm mailparse.tar.gz

  mkdir -p /usr/src/php/ext/apcu
  # The new apcu-4.0.8 doesn't compile
  curl -SL "https://pecl.php.net/get/apcu-4.0.7.tgz" -o apcu.tar.gz
  tar -zxf apcu.tar.gz -C /usr/src/php/ext/apcu --strip-components=1
  rm apcu.tar.gz

  mkdir -p /usr/src/php/ext/suhosin
  curl -SL "https://github.com/stefanesser/suhosin/archive/0.9.38.tar.gz" -o suhosin.tar.gz
  tar -zxf suhosin.tar.gz -C /usr/src/php/ext/suhosin --strip-components=1
  rm suhosin.tar.gz

  pushd /usr/src/php
  rm -f configure
  ./buildconf --force
  ./configure \
      --prefix=$PHP56_DIR \
      --with-config-file-scan-dir=$APP_DIR \
      --disable-cgi \
      --disable-memcached-sasl \
      --enable-apcu \
      --enable-bcmath=shared \
      --enable-calendar=shared \
      --enable-exif=shared \
      --enable-fpm \
      --enable-ftp=shared \
      --enable-gd-native-ttf \
      --enable-intl=shared \
      --enable-mailparse \
      --enable-mbstring=shared \
      --enable-memcache=shared \
      --enable-memcached=shared \
      --enable-mysqlnd \
      --enable-opcache \
      --enable-pcntl=shared \
      --enable-shared \
      --enable-shmop=shared \
      --enable-soap=shared \
      --enable-sockets \
      --enable-suhosin=shared \
      --enable-zip \
      --with-bz2 \
      --with-curl \
      --with-gettext=shared \
      --with-gd=shared \
      --with-mcrypt \
      --with-pdo_sqlite=shared,/usr \
      --with-pdo-pgsql \
      --with-pgsql \
      --with-sqlite3=shared,/usr \
      --with-xmlrpc=shared \
      --with-xsl=shared \
      --with-fpm-user=www-data \
      --with-fpm-group=www-data \
      --with-mysql=mysqlnd \
      --with-mysqli=mysqlnd \
      --with-pdo-mysql=mysqlnd \
      --with-openssl \
      --with-pcre-regex \
      --with-readline \
      --with-recode \
      --with-zlib

  make -j"$(nproc)"
  make install
  make clean
  popd
  rm -rf /usr/src/php
  strip ${PHP56_DIR}/bin/php ${PHP56_DIR}/sbin/php-fpm
  # Defaults to PHP5.6
  ln -s ${PHP56_DIR} ${PHP_DIR}
}

# Build PHP
function build_php7 {
  curl -SL "https://downloads.php.net/~ab/php-$PHP70_VERSION.tar.gz" -o php7.tar.gz
  mkdir -p /usr/src/php7
  tar -zxf php7.tar.gz -C /usr/src/php7 --strip-components=1
  rm php7.tar.gz

  # TODO: Install 3rd party extensions.

  pushd /usr/src/php7
  rm -f configure
  ./buildconf --force
  ./configure \
      --prefix=$PHP7_DIR \
      --with-config-file-scan-dir=$APP_DIR \
      --disable-cgi \
      --enable-bcmath=shared \
      --enable-calendar=shared \
      --enable-exif=shared \
      --enable-fpm \
      --enable-ftp=shared \
      --enable-gd-native-ttf \
      --enable-intl=shared \
      --enable-mbstring=shared \
      --enable-mysqlnd \
      --enable-opcache \
      --enable-pcntl=shared \
      --enable-shared \
      --enable-shmop=shared \
      --enable-soap=shared \
      --enable-sockets \
      --enable-zip \
      --enable-phpdbg=no \
      --with-bz2 \
      --with-mcrypt \
      --with-curl \
      --with-gettext=shared \
      --with-gd=shared \
      --with-pdo_sqlite=shared,/usr \
      --with-sqlite3=shared,/usr \
      --with-xmlrpc=shared \
      --with-xsl=shared \
      --with-fpm-user=www-data \
      --with-fpm-group=www-data \
      --with-mysqli=mysqlnd \
      --with-pdo-mysql=mysqlnd \
      --with-pdo-pgsql \
      --with-pgsql \
      --with-openssl \
      --with-pcre-regex \
      --with-readline \
      --with-recode \
      --with-zlib

  make -j"$(nproc)"
  make install
  make clean
  popd
  rm -rf /usr/src/php7
  strip ${PHP7_DIR}/bin/php ${PHP7_DIR}/sbin/php-fpm
}

function install_composer {
  curl -sS https://getcomposer.org/installer | \
    ${PHP56_DIR}/bin/php -- \
    --install-dir=/usr/local/bin \
    --filename=composer
}

function import_gpg_keys {
  local NGINX_GPG_KEYS=" \
    F5806B4D \
    A524C53E \
    A1C052F8 \
    2C172083 \
    7ADB39A8 \
    6C7E5E82 \
    7BD9BF62"

  gpg --keyserver pgp.mit.edu --recv-keys $NGINX_GPG_KEYS

  local PHP_GPG_KEYS=" \
      0BD78B5F97500D450838F95DFE857D9A90D90EC1 \
      6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3"

  gpg --keyserver pgp.mit.edu --recv-keys $PHP_GPG_KEYS
}

apt-get update

apt-get install -y $BUILD_TOOLS $BUILD_DEPS --no-install-recommends

import_gpg_keys
# TODO(slangley): Decided on what to do about OpenSSL.
# build_openssl
build_nginx
build_php56
build_php7
install_composer

apt-get purge -y --auto-remove -o \
    APT::AutoRemove::RecommendsImportant=false -o \
    APT::AutoRemove::SuggestsImportant=false $BUILD_TOOLS $BUILD_DEPS

rm -rf /var/lib/apt/lists/*
