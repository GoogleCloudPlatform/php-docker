#!/bin/bash

set -ex

echo "Building memcached for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memcached"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    pecl download memcached
    # determine the version of the latest memcached
    MEMCACHED_VERSION=$(ls memcached-*.tgz | \
        sed 's/memcached-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\.tgz/\1/')
    PACKAGE_VERSION="${MEMCACHED_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${MEMCACHED_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}
    mv memcached-${MEMCACHED_VERSION}.tgz \
       ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz
    mkdir -p ${PACKAGE_DIR}
    tar zxvf ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz \
        -C ${PACKAGE_DIR} --strip-components=1
elif [ ${SHORT_VERSION} == '70' ]; then
    # TODO: Use a stable version from pecl once available
    git clone -b php7 https://github.com/php-memcached-dev/php-memcached \
        memcached
    pushd memcached
    CHASH=`git rev-parse HEAD`
    DATE=`date +%Y%m%d`
    MEMCACHED_VERSION="${DATE}-git-${CHASH}"
    PACKAGE_VERSION="${MEMCACHED_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${MEMCACHED_VERSION}-${FULL_VERSION}"
    PACKAGE_DIR=${PNAME}-${PACKAGE_VERSION}
    popd
    rm -rf memcached/.git
    mv memcached ${PACKAGE_DIR}
    tar -cvzf ${PNAME}-${PACKAGE_VERSION}.orig.tar.gz ${PACKAGE_DIR}
elif [ ${SHORT_VERSION} == '71' ]; then
    echo "Not yet implemented"
    exit 0
fi

cp -R ${DEB_BUILDER_DIR}/extensions/memcached/debian ${PACKAGE_DIR}
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/rules.in \
         > ${PACKAGE_DIR}/debian/rules
rm ${PACKAGE_DIR}/debian/rules.in
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
rm ${PACKAGE_DIR}/debian/control.in
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-memcached.install \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-memcached.install
rm ${PACKAGE_DIR}/debian/gcp-php-memcached.install
pushd ${PACKAGE_DIR}
dch --create -v "${MEMCACHED_VERSION}-${FULL_VERSION}" \
    --package gcp-php${SHORT_VERSION}-memcached --empty -M \
    "Build ${MEMCACHED_VERSION}-${FULL_VERSION} of gcp-php${SHORT_VERSION}-memcached"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
