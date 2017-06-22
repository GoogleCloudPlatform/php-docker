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

if [ "$#" -lt 1 ]; then
    echo 'usage: build.sh PHP_VERSIONS'
    exit 1
fi

if [ -z "${BUILD_DIR}" ]; then
    BUILD_DIR='/build'
fi

export BUILD_DIR
export ARTIFACT_DIR='/workspace/pkg'
export DEB_BUILDER_DIR='/workspace'

mkdir -p ${BUILD_DIR} ${ARTIFACT_DIR}

# Remove everything and start fresh
rm -rf ${BUILD_DIR}/*

cp -R ${DEB_BUILDER_DIR}/debian ${BUILD_DIR}

PHP_VERSIONS=${1}

EXTENSIONS=${2}
if [ -z "$EXTENSIONS" ]; then
    # Explicitly declaring because some extenions depend on others (pq depends on raphf)
    EXTENSIONS="apcu,apcu_bc,ev,event,grpc,imagick,jsonc,mailparse,memcache,memcached,mongodb,oauth,phalcon,protobuf,raphf,pq,rdkafka,redis,suhosin,libuv,cassandra-cpp-driver,cassandra"
fi


cd ${BUILD_DIR}

# update dependencies
apt-get upgrade -y

build_php_version()
{
    export FULL_VERSION=$1
    export PHP_VERSION=$(echo ${FULL_VERSION} | sed 's/-.*//')
    export BASE_VERSION=$(echo ${PHP_VERSION} | \
        sed 's/\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')
    export SHORT_VERSION=$(echo ${BASE_VERSION} | tr -d ".")
    export PACKAGE_NAME="gcp-php${SHORT_VERSION}"
    PHP_PACKAGE="gcp-php${SHORT_VERSION}_${FULL_VERSION}_amd64.deb"

    if [ -e "${ARTIFACT_DIR}/${PHP_PACKAGE}" ]; then
        echo "$PHP_PACKAGE already exists, skipping"
    else
      echo "Building ${PACKAGE_NAME} version ${FULL_VERSION}"
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
          ${PACKAGE_NAME}_${PHP_VERSION}.orig.tar.gz
      tar xzf ${PACKAGE_NAME}_${PHP_VERSION}.orig.tar.gz
      mv php-${PHP_VERSION} ${PACKAGE_NAME}-${PHP_VERSION}
      cp -r debian ${PACKAGE_NAME}-${PHP_VERSION}/debian
      pushd ${PACKAGE_NAME}-${PHP_VERSION}
      if [[ ${PHP_VERSION} =~ ^5 ]]; then
          echo "Removing ext/json"
          rm -rf ext/json
          pushd ..
          rm ${PACKAGE_NAME}_${PHP_VERSION}.orig.tar.gz
          tar cvzf ${PACKAGE_NAME}_${PHP_VERSION}.orig.tar.gz \
              ${PACKAGE_NAME}-${PHP_VERSION}
          popd
      fi
      envsubst '${SHORT_VERSION}' < debian/rules.in > debian/rules
      chmod +x debian/rules
      envsubst '${SHORT_VERSION}' < debian/control.in > debian/control
      envsubst '${SHORT_VERSION}' < debian/patches/series.in > \
               debian/patches/series
      envsubst '${SHORT_VERSION}' < debian/gcp-php.dirs.in > \
               debian/${PACKAGE_NAME}.dirs
      envsubst '${SHORT_VERSION}' < debian/gcp-php.install.in > \
               debian/${PACKAGE_NAME}.install
      envsubst '${SHORT_VERSION}' < debian/php-enmod.in > \
               debian/php${SHORT_VERSION}-enmod
      chmod 755 debian/php${SHORT_VERSION}-enmod
      envsubst '${SHORT_VERSION}' < debian/php-dismod.in > \
               debian/php${SHORT_VERSION}-dismod
      chmod 755 debian/php${SHORT_VERSION}-dismod

      # Remove the templates
      rm debian/*.in debian/*/*.in

      dch --create -v ${FULL_VERSION} \
          --package gcp-php${SHORT_VERSION} --empty -M \
          "Build ${FULL_VERSION} of gcp-php${SHORT_VERSION}"
      dpkg-buildpackage -us -uc -j"$(nproc)"
      popd

      cp $PHP_PACKAGE $ARTIFACT_DIR
    fi
}

build_php_extension()
{
    echo "Building $1 extension..."
    ${DEB_BUILDER_DIR}/extensions/$1/build.sh
}

for VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n"); do
    build_php_version $VERSION

    # install the php package
    dpkg -i "$ARTIFACT_DIR/$PHP_PACKAGE"
    # Make it a default
    rm -rf ${PHP_DIR}
    ln -sf /opt/php${SHORT_VERSION} ${PHP_DIR}

    # build extensions
    for EXTENSION in $(echo ${EXTENSIONS} | tr "," "\n"); do
        build_php_extension $EXTENSION
    done
done
