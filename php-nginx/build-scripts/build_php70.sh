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
gpg --verify php7.tar.gz.asc
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

# TODO: Use the stable version of apcu from pecl once available.
# With the 5.1.2 source from the PECL, it doesn'r recognize the
# --enable-apcu option.
# mkdir -p ${PHP_SRC}/ext/apcu
# curl -SL "https://pecl.php.net/get/apcu" -o apcu.tar.gz
# tar -zxf apcu.tar.gz -C ${PHP_SRC}/ext/apcu --strip-components=1
# rm apcu.tar.gz
git clone https://github.com/krakjoe/apcu.git ${PHP_SRC}/ext/apcu

pushd ${PHP_SRC}
rm -f configure
./buildconf --force
./configure \
    --prefix=$PHP7_DIR \
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

# Install shared extensions
${PHP7_DIR}/bin/pecl install mongodb

# TODO: Use stable version of memcache from pecl once available
git clone https://github.com/websupport-sk/pecl-memcache.git /tmp/memcache
pushd /tmp/memcache
${PHP7_DIR}/bin/phpize
./configure
make
make install
popd
rm -rf /tmp/memcache
