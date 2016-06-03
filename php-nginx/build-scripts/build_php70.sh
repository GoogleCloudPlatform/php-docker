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


# A shell script for installing PHP 7.0.
set -xe

PHP_SRC=/usr/src/php7

curl -SL "http://php.net/get/php-$PHP70_VERSION.tar.gz/from/this/mirror" -o php7.tar.gz
curl -SL "http://us2.php.net/get/php-$PHP70_VERSION.tar.gz.asc/from/this/mirror" -o php7.tar.gz.asc

# Create combined binary keys
cat /gpgkeys/php70/* | gpg --dearmor > /gpgkeys/php70.gpg

# Verify only with specific public keys
gpg --no-default-keyring --keyring /gpgkeys/php70.gpg --verify php7.tar.gz.asc

mkdir -p ${PHP_SRC}
tar -zxf php7.tar.gz -C ${PHP_SRC} --strip-components=1
rm php7.tar.gz
rm php7.tar.gz.asc

# TODO: Install more 3rd party extensions.

# TODO: Use stable version of memcached from pecl once available
git clone -b php7 https://github.com/php-memcached-dev/php-memcached ${PHP_SRC}/ext/memcached

# No need for jsonc replacement.

mkdir -p ${PHP_SRC}/ext/mailparse
curl -SL "https://pecl.php.net/get/mailparse" -o mailparse.tar.gz
tar -zxf mailparse.tar.gz -C ${PHP_SRC}/ext/mailparse --strip-components=1
rm mailparse.tar.gz

# APCu
mkdir -p ${PHP_SRC}/ext/apcu
curl -SL "https://pecl.php.net/get/apcu-5.1.4.tgz" -o apcu.tar.gz
tar -zxf apcu.tar.gz -C ${PHP_SRC}/ext/apcu --strip-components=1
rm apcu.tar.gz

# APC compatibility layer for APCu
mkdir -p ${PHP_SRC}/ext/apcu-bc
curl -SL "https://pecl.php.net/get/apcu_bc-1.0.3.tgz" -o apcu-bc.tar.gz
tar -zxf apcu-bc.tar.gz -C ${PHP_SRC}/ext/apcu-bc --strip-components=1
rm apcu-bc.tar.gz

pushd ${PHP_SRC}
patch -p1 < /build-scripts/php7-parse_str_harden.patch
rm -f configure
./buildconf --force
./configure \
    --prefix=$PHP7_DIR \
    --with-config-file-scan-dir=$APP_DIR:${PHP7_DIR}/lib/conf.d \
    --disable-cgi \
    --disable-memcached-sasl \
    --enable-apc \
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
rm -rf ${PHP_SRC}
strip ${PHP7_DIR}/bin/php ${PHP7_DIR}/sbin/php-fpm

# Create a directory for additional config files.
mkdir -p ${PHP7_DIR}/lib/conf.d

# Install shared extensions
${PHP7_DIR}/bin/pecl install mongodb

# TODO: Use stable version of memcache from pecl once available
git clone https://github.com/websupport-sk/pecl-memcache.git /tmp/memcache
pushd /tmp/memcache
${PHP7_DIR}/bin/phpize
./configure --with-php-config=${PHP7_DIR}/bin/php-config
make
make install
popd
rm -rf /tmp/memcache

# TODO: Use stable version of redis from pecl once available
git clone -b php7 https://github.com/phpredis/phpredis.git /tmp/redis
pushd /tmp/redis
${PHP7_DIR}/bin/phpize
./configure --with-php-config=${PHP7_DIR}/bin/php-config
make
make install
popd
rm -rf /tmp/redis

rm -rf /tmp/pear
