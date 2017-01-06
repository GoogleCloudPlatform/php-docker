#!/bin/bash

set -ex

source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building memcached for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-memcached"

# Download the source
if [ ${SHORT_VERSION} == '56' ]; then
    download_from_pecl memcached
elif [ ${SHORT_VERSION} == '70' ]; then
    # TODO: Use a stable version from pecl once available
    git clone -b php7 https://github.com/php-memcached-dev/php-memcached \
        memcached
    pushd memcached
    CHASH=`git rev-parse HEAD`
    DATE=`date +%Y%m%d`
    EXT_VERSION="${DATE}-git-${CHASH}"
    PACKAGE_VERSION="${EXT_VERSION}-${PHP_VERSION}"
    PACKAGE_FULL_VERSION="${EXT_VERSION}-${FULL_VERSION}"
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
chmod +x ${PACKAGE_DIR}/debian/rules
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/control.in \
         > ${PACKAGE_DIR}/debian/control
envsubst '${SHORT_VERSION}' < ${PACKAGE_DIR}/debian/gcp-php-memcached.install.in \
         > ${PACKAGE_DIR}/debian/gcp-php${SHORT_VERSION}-memcached.install
rm ${PACKAGE_DIR}/debian/*.in
pushd ${PACKAGE_DIR}
dch --create -v "${EXT_VERSION}-${FULL_VERSION}" \
    --package ${PNAME} --empty -M \
    "Build ${EXT_VERSION}-${FULL_VERSION} of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
popd
