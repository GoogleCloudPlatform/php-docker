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
export ARTIFACT_LIB_DIR="${ARTIFACT_DIR}/libraries"
export DEB_BUILDER_DIR='/workspace'

mkdir -p ${BUILD_DIR} ${ARTIFACT_LIB_DIR}

# Remove everything and start fresh
rm -rf ${BUILD_DIR}/*

cp -R ${DEB_BUILDER_DIR}/debian ${BUILD_DIR}

PHP_VERSIONS=${1}

EXTENSIONS=${2}
if [ -z "$EXTENSIONS" ]; then
    # Explicitly declaring because some extenions depend on others (pq depends on raphf)
    EXTENSIONS="amqp,apcu,apcu_bc,apm,bitset,cassandra,couchbase,ds,eio,ev,event,grpc,hprose,imagick,igbinary,jsonc,jsond,krb5,libsodium,lua,lzf,mailparse,memcache,memcached,memprof,mongo,mongodb,oauth,opencensus,phalcon,protobuf,raphf,pq,rdkafka,redis,seaslog,stackdriver_debugger,stomp,suhosin,swoole,sync,tcpwrap,timezonedb,v8js,vips,yaconf,yaf,yaml"
fi

LIBRARIES=${3}
if [ -z "$LIBRARIES" ]; then
    LIBRARIES="cassandra-cpp-driver,libv8,libvips"
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
    export ARTIFACT_PKG_DIR="${ARTIFACT_DIR}/${FULL_VERSION}"
    if [ "${SHORT_VERSION}" == "72" ]; then
        export EXTRA_DEPS="libsodium18, "
        export EXTRA_OPTS="--with-sodium"
    else
        export EXTRA_DEPS=""
        export EXTRA_OPTS=""
    fi
    mkdir -p ${ARTIFACT_PKG_DIR}

    ls -l ${ARTIFACT_PKG_DIR}

    if [ -e "${ARTIFACT_PKG_DIR}/${PHP_PACKAGE}" ]; then
        echo "$PHP_PACKAGE already exists, skipping"
    else
      echo "Building ${PACKAGE_NAME} version ${FULL_VERSION}"

      if [[ "${PHP_VERSION}" == *"alpha"* ]] || [[ "${PHP_VERSION}" == *"beta"* ]] || [[ "${PHP_VERSION}" == *"RC"* ]]; then
          # Set PRE_GA_PACKAGE_BASE_URL for overriding the behavior
          if [ -z "${PRE_GA_PACKAGE_BASE_URL}" ]; then
              # Defaults to https://downloads.php.net/~pollita/
              PRE_GA_PACKAGE_BASE_URL="https://downloads.php.net/~pollita/"
          fi
          curl -sL "${PRE_GA_PACKAGE_BASE_URL}php-${PHP_VERSION}.tar.gz" \
              > php-${PHP_VERSION}.tar.gz
          curl -sL "${PRE_GA_PACKAGE_BASE_URL}php-${PHP_VERSION}.tar.gz.asc" \
              > php-${PHP_VERSION}.tar.gz.asc
      else
          curl -sL "https://php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror" \
              > php-${PHP_VERSION}.tar.gz
          curl -sL "https://php.net/get/php-${PHP_VERSION}.tar.gz.asc/from/this/mirror" \
              > php-${PHP_VERSION}.tar.gz.asc
      fi
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
      envsubst '${SHORT_VERSION} ${EXTRA_OPTS}' < debian/rules.in > debian/rules
      chmod +x debian/rules
      envsubst '${SHORT_VERSION} ${EXTRA_DEPS}' < debian/control.in > debian/control
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

      cp $PHP_PACKAGE $ARTIFACT_PKG_DIR
    fi
}

build_library()
{
    echo "Building $1 library..."
    ${DEB_BUILDER_DIR}/libraries/$1/build.sh
}

build_php_extension()
{
    echo "Building $1 extension..."
    ${DEB_BUILDER_DIR}/extensions/$1/build.sh
}

for LIBRARY in $(echo ${LIBRARIES} | tr "," "\n"); do
    build_library $LIBRARY
done

for VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n"); do
    build_php_version $VERSION

    # install the php package
    dpkg -i "$ARTIFACT_PKG_DIR/$PHP_PACKAGE"
    # Make it a default
    rm -rf ${PHP_DIR}
    ln -sf /opt/php${SHORT_VERSION} ${PHP_DIR}

    # build extensions
    if [[ "${SHORT_VERSION}" > "72" ]]; then
        EXTENSIONS=$(echo $EXTENSIONS | sed -e 's/apm,//g')
        EXTENSIONS=$(echo $EXTENSIONS | sed -e 's/cassandra,//g')
        EXTENSIONS=$(echo $EXTENSIONS | sed -e 's/v8js,//g')
    fi
    for EXTENSION in $(echo ${EXTENSIONS} | tr "," "\n"); do
        build_php_extension $EXTENSION
    done
done
