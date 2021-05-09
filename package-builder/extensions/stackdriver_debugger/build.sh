#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/functions.sh

echo "Building stackdriver-debugger for gcp-php${SHORT_VERSION}"

PNAME="gcp-php${SHORT_VERSION}-stackdriver-debugger"

if [ ${SHORT_VERSION} == '56' ]; then
    echo "PHP 5.6 is not supported"
    exit 0
fi
# elif [ ${SHORT_VERSION} == '80' ]; then

download_from_git https://github.com/frost-byte/stackdriver-debugger-php-extension.git 0.3.0

    # build_package stackdriver_debugger
# else
#     download_from_pecl stackdriver_debugger
# fi
build_package stackdriver_debugger
