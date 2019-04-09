#!/bin/bash

set -e

DIR="$( dirname "${BASH_SOURCE[0]}" )"

if [ -z "${DEB_TMP_DIR}" ]; then
    DEB_TMP_DIR='/tmp/php-build'
fi

if [ -z "${DEBIAN_GCS_PATH}" ]; then
    DEBIAN_GCS_PATH='gs://php-mvm-a/packages'
fi

if [ -z "${UBUNTU_GCS_PATH}" ]; then
    UBUNTU_GCS_PATH='gs://php-mvm-a/ubuntu-packages'
fi

if [ "${1}" == "debian" ]; then
    GCS_PATH=${DEBIAN_GCS_PATH}
    TARGET_DIR=${DEB_TMP_DIR}/debian
    GCS_DESTINATION='gcp-php-runtime-jessie'
else
    GCS_PATH=${UBUNTU_GCS_PATH}
    TARGET_DIR=${DEB_TMP_DIR}/ubuntu
    GCS_DESTINATION='gcp-php-runtime-xenial'
fi

mkdir -p ${TARGET_DIR}

PHP_VERSIONS=`sed -n '/PHP_VERSIONS/{n;p;}' "${DIR}/ubuntu-packages.cfg" | grep -o '".*"' | sed 's/"//g'`

IFS=',' read -ra VERSIONS <<< "${PHP_VERSIONS}"

echo 'Downloading deb packages'
echo '============================================='

for v in "${VERSIONS[@]}"; do
    gsutil -m cp "${GCS_PATH}/${v}/*.deb" $TARGET_DIR
done

gsutil -m cp "${GCS_PATH}/libraries/*.deb" $TARGET_DIR

echo 'Dedupping deb packages'
echo '============================================='

php /google/data/ro/teams/php-cloud/php-debian-package-dedup/dedup.php "${1}"

# We're going to mirror rapture's naming scheme to make the switch to GCS as
# seamless as possible.
gsutil -m rm -r gs://gcp-php-packages/${GCS_DESTINATION}
gsutil -m rm -r gs://gcp-php-packages/${GCS_DESTINATION}-unstable

gsutil -m cp ${TARGET_DIR}/*.deb gs://gcp-php-packages/${GCS_DESTINATION}
gsutil -m cp ${TARGET_DIR}/*.deb gs://gcp-php-packages/${GCS_DESTINATION}-unstable

readonly RUNTIME_DIST="${GCS_DESTINATION}-$(date +%Y%m%d-1)"
gsutil -m cp ${TARGET_DIR}/*.deb "gs://gcp-php-packages/${RUNTIME_DIST}"

echo ""
echo "-----------------------------------------------------------------------"
echo "New RUNTIME_DISTRIBUTION value: ${RUNTIME_DIST}"
echo "-----------------------------------------------------------------------"
