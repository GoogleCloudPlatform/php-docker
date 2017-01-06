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

# Remove everything and start fresh
rm -rf ${BUILD_DIR}/*

cp -R ${DEB_BUILDER_DIR}/debian ${BUILD_DIR}

PHP_VERSIONS=${1}

cd ${BUILD_DIR}

for FULL_VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n"); do
    export FULL_VERSION
    export PHP_VERSION=$(echo ${FULL_VERSION} | sed 's/-.*//')
    export BASE_VERSION=$(echo ${PHP_VERSION} | \
        sed 's/\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')
    export SHORT_VERSION=$(echo ${BASE_VERSION} | tr -d ".")
    echo "Building gcp-php-${PHP_VERSION} version ${FULL_VERSION}"
    curl -sL "https://php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror" \
        > php-${PHP_VERSION}.tar.gz
    curl -sL \
        "https://php.net/get/php-${PHP_VERSION}.tar.gz.asc/from/this/mirror" \
            > php-${PHP_VERSION}.tar.gz.asc
    cat ${DEB_BUILDER_DIR}/gpgkeys/php${SHORT_VERSION}/* | gpg --dearmor \
        > ${DEB_BUILDER_DIR}/gpgkeys/php${SHORT_VERSION}.gpg
    gpg --no-default-keyring --keyring \
        ${DEB_BUILDER_DIR}/gpgkeys/php${SHORT_VERSION}.gpg \
        --verify php-${PHP_VERSION}.tar.gz.asc
    rm php-${PHP_VERSION}.tar.gz.asc
    mv php-${PHP_VERSION}.tar.gz \
        gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz
    tar xzf gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz
    mv php-${PHP_VERSION} gcp-php-${PHP_VERSION}-${PHP_VERSION}
    cp -r debian gcp-php-${PHP_VERSION}-${PHP_VERSION}/debian
    pushd gcp-php-${PHP_VERSION}-${PHP_VERSION}
    if [[ ${PHP_VERSION} =~ ^5 ]]; then
        echo "Removing ext/json"
        rm -rf ext/json
        pushd ..
        rm gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz
        tar cvzf gcp-php-${PHP_VERSION}_${PHP_VERSION}.orig.tar.gz \
            gcp-php-${PHP_VERSION}-${PHP_VERSION}
        popd
    fi
    envsubst '${PHP_VERSION},${SHORT_VERSION}' < debian/rules.in > debian/rules
    rm debian/rules.in
    chmod +x debian/rules
    envsubst \
        '${PHP_VERSION},${SHORT_VERSION}' < debian/control.in > debian/control
    rm debian/control.in
    envsubst '${SHORT_VERSION}' < debian/patches/series.in > \
             debian/patches/series
    rm debian/patches/series.in
    envsubst '${SHORT_VERSION}' < debian/gcp-php.dirs.in > \
             debian/gcp-php-${PHP_VERSION}.dirs
    rm debian/gcp-php.dirs.in
    envsubst '${SHORT_VERSION}' < debian/gcp-php.install.in > \
             debian/gcp-php-${PHP_VERSION}.install
    rm debian/gcp-php.install.in
    envsubst '${SHORT_VERSION}' < debian/php-enmod.in > \
             debian/php${SHORT_VERSION}-enmod
    rm debian/php-enmod.in
    chmod 755 debian/php${SHORT_VERSION}-enmod
    envsubst '${SHORT_VERSION}' < debian/php-dismod.in > \
             debian/php${SHORT_VERSION}-dismod
    rm debian/php-dismod.in
    chmod 755 debian/php${SHORT_VERSION}-dismod

    dch --create -v ${FULL_VERSION} \
        --package gcp-php-${PHP_VERSION} --empty -M \
        "Build ${FULL_VERSION} of gcp-php-${PHP_VERSION}"
    dpkg-buildpackage -us -uc -j"$(nproc)"
    popd
    # build extensions
    dpkg -i gcp-php-${PHP_VERSION}_${FULL_VERSION}_amd64.deb
    # Make it a default
    rm -rf ${PHP_DIR}
    ln -sf /opt/php${SHORT_VERSION} ${PHP_DIR}
    find ${DEB_BUILDER_DIR}/extensions -name 'build.sh' -exec {} \;
done
