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


# A shell script for building openssl
set -xe

# Build OpenSSL
curl -SL "http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" -o openssl.tar.gz
mkdir -p /usr/src/openssl
tar -zxf openssl.tar.gz -C /usr/src/openssl --strip-components=1

pushd /usr/src/openssl

patch -p1 < /tmp/openssl-version-script.patch

./Configure \
    --prefix=/usr \
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
