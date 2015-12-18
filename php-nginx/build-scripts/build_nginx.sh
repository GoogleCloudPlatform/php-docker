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


# A shell script for installing nginx.
set -xe

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
    --with-openssl=/usr

make
make install
popd
rm -rf /usr/src/nginx
