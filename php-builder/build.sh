#!/bin/bash
# Copyright 2016 Google Inc.
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

set -ex

if [ "$#" -ne 1 ]; then
    echo 'usage: build.sh PHP_VERSIONS'
    exit 1
fi

if [ -z "${BUILD_DIR}" ]; then
    BUILD_DIR='/workspace'
fi

mkdir -p ${BUILD_DIR}
cp -R ${PHP_BUILDER_DIR}/debian ${BUILD_DIR}

PHP_VERSIONS=${1}

for FULL_VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n"); do 
    PHP_VERSION=$(echo ${FULL_VERSION} | sed 's/-.*//')
    BASE_VERSION=$(echo ${PHP_VERSION} | \
        sed 's/\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')
    SHORT_VERSION=$(echo ${BASE_VERSION} | tr -d ".")
    echo "Building gcp-php-${PHP_VERSION} version ${FULL_VERSION}"
    cd ${BUILD_DIR}
    curl -sL "https://php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror" \
        > php-${PHP_VERSION}.tar.gz
    curl -sL \
        "https://php.net/get/php-${PHP_VERSION}.tar.gz.asc/from/this/mirror" \
            > php-${PHP_VERSION}.tar.gz.asc
    cat /gpgkeys/php${SHORT_VERSION}/* | gpg --dearmor \
        > /gpgkeys/php${SHORT_VERSION}.gpg
    gpg --no-default-keyring --keyring /gpgkeys/php${SHORT_VERSION}.gpg \
        --verify php-${PHP_VERSION}.tar.gz.asc
    rm php-${PHP_VERSION}.tar.gz.asc
    mv php-${PHP_VERSION}.tar.gz \
        gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz
    tar xzf gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz
    mv php-${PHP_VERSION} gcp-php-${PHP_VERSION}-${PHP_VERSION}
    cp -r debian gcp-php-${PHP_VERSION}-${PHP_VERSION}/debian
    cd gcp-php-${PHP_VERSION}-${PHP_VERSION}
    if [[ ${PHP_VERSION} =~ ^5 ]]; then
        echo "Removing ext/json"
        rm -rf ext/json
        pushd ..
        rm gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz
        tar cvzf gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz \
            gcp-php-${PHP_VERSION}-${PHP_VERSION}
        popd
    fi
    sed -i -e "s/PHP_VERSION/${PHP_VERSION}/" debian/control debian/rules
    sed -i -e "s/SHORT_VERSION/${SHORT_VERSION}/" debian/control debian/rules \
        debian/patches/series
    dch --create -v ${FULL_VERSION} \
        --package gcp-php-${PHP_VERSION} --empty -M \
        "Build ${FULL_VERSION} of gcp-php-${PHP_VERSION}"
    dpkg-buildpackage -us -uc
done
