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


# A shell script for installing PHP 5.6.
set -xe

PHP_SRC=/usr/src/php

curl -SL "http://php.net/get/php-$PHP56_VERSION.tar.gz/from/this/mirror" -o php.tar.gz
curl -SL "http://us2.php.net/get/php-$PHP56_VERSION.tar.gz.asc/from/this/mirror" -o php.tar.gz.asc
gpg --verify php.tar.gz.asc
mkdir -p ${PHP_SRC}
tar -zxf php.tar.gz -C ${PHP_SRC} --strip-components=1
rm php.tar.gz
rm php.tar.gz.asc

mkdir -p ${PHP_SRC}/ext/memcached
curl -SL "http://pecl.php.net/get/memcached" -o memcached.tar.gz
tar -zxf memcached.tar.gz -C ${PHP_SRC}/ext/memcached --strip-components=1
rm memcached.tar.gz

rm -rf ${PHP_SRC}/ext/json
mkdir -p ${PHP_SRC}/ext/json
curl -SL "https://pecl.php.net/get/jsonc" -o jsonc.tar.gz
tar -zxf jsonc.tar.gz -C ${PHP_SRC}/ext/json --strip-components=1
rm jsonc.tar.gz

# The newest 3.0.0 doesn't build with PHP56.
mkdir -p ${PHP_SRC}/ext/mailparse
curl -SL "https://pecl.php.net/get/mailparse-2.1.6.tgz" -o mailparse.tar.gz
tar -zxf mailparse.tar.gz -C ${PHP_SRC}/ext/mailparse --strip-components=1
rm mailparse.tar.gz

mkdir -p ${PHP_SRC}/ext/apcu
# The newest 5.1.2 doesn't build with PHP 5.6.
curl -SL "https://pecl.php.net/get/apcu-4.0.10.tgz" -o apcu.tar.gz
tar -zxf apcu.tar.gz -C ${PHP_SRC}/ext/apcu --strip-components=1
rm apcu.tar.gz

mkdir -p ${PHP_SRC}/ext/suhosin
curl -SL "https://github.com/stefanesser/suhosin/archive/0.9.38.tar.gz" -o suhosin.tar.gz
tar -zxf suhosin.tar.gz -C ${PHP_SRC}/ext/suhosin --strip-components=1
rm suhosin.tar.gz

pushd /usr/src/php
rm -f configure
./buildconf --force
./configure \
    --prefix=$PHP56_DIR \
    --with-config-file-scan-dir=$APP_DIR:${PHP56_DIR}/lib/conf.d \
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

# Create a directory for additional config files.
mkdir -p ${PHP56_DIR}/lib/conf.d

# Install shared extensions
${PHP56_DIR}/bin/pecl install memcache
${PHP56_DIR}/bin/pecl install mongodb
${PHP56_DIR}/bin/pecl install redis

rm -rf /tmp/pear

# Install composer
curl -sS https://getcomposer.org/installer | \
    ${PHP56_DIR}/bin/php -- \
    --install-dir=/usr/local/bin \
    --filename=composer
