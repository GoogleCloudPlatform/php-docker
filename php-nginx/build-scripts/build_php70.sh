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

curl -SL "http://php.net/get/php-$PHP70_VERSION.tar.gz/from/this/mirror" -o php7.tar.gz
curl -SL "http://us2.php.net/get/php-$PHP70_VERSION.tar.gz.asc/from/this/mirror" -o php7.tar.gz.asc
gpg --verify php7.tar.gz.asc
mkdir -p /usr/src/php7
tar -zxf php7.tar.gz -C /usr/src/php7 --strip-components=1
rm php7.tar.gz
rm php7.tar.gz.asc

# TODO: Install more 3rd party extensions.

# TODO: Use stable version of memcached from pecl once available
git clone -b php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php7/ext/memcached

pushd /usr/src/php7
rm -f configure
./buildconf --force
./configure \
    --prefix=$PHP7_DIR \
    --with-config-file-scan-dir=$APP_DIR \
    --disable-cgi \
    --disable-memcached-sasl \
    --enable-bcmath=shared \
    --enable-calendar=shared \
    --enable-exif=shared \
    --enable-fpm \
    --enable-ftp=shared \
    --enable-gd-native-ttf \
    --enable-intl=shared \
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
rm -rf /usr/src/php7
strip ${PHP7_DIR}/bin/php ${PHP7_DIR}/sbin/php-fpm
