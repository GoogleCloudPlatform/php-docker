#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building xmlrpc for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-xmlrpc"

if [ ${SHORT_VERSION} == '80' ]; then
    # Download the source
    download_from_pecl xmlrpc 1.0.0RC2

    build_package xmlrpc
else
    echo 'xmlrpc is builtin already'
    exit 0
fi
