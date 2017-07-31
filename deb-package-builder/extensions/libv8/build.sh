#!/bin/bash
set -ex
source ${DEB_BUILDER_DIR}/extensions/functions.sh

echo "Building ev for gcp-php${SHORT_VERSION}"

PNAME="libv8"
VERSION=5.9.223

OUTPUT_FILE=${PNAME}_${VERSION}-1~gcp8+1_amd64.deb

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=`pwd`/depot_tools:"$PATH"

# Download v8
fetch v8
pushd v8

# (optional) If you'd like to build a certain version:
git checkout ${VERSION}
gclient sync

cp -R ${DEB_BUILDER_DIR}/extensions/libv8/debian .

dch --create -v "${VERSION}-1~gcp8+1" \
    --package ${PNAME} --empty -M \
    "Build ${VERSION}-1~gcp8+1 of ${PNAME}"
dpkg-buildpackage -us -uc -j"$(nproc)"
cp ../${OUTPUT_FILE} ${ARTIFACT_DIR}


# Setup GN
# tools/dev/v8gen.py -vv x64.release -- is_component_build=true
#
# # Build
# ninja -C out.gn/x64.release/
#
# # Install to /opt/v8/
# sudo mkdir -p /opt/v8/{lib,include}
# sudo cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin \
#   out.gn/x64.release/icudtl.dat /opt/v8/lib/
# sudo cp -R include/* /opt/v8/include/

popd
