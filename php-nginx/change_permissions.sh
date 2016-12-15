#!/bin/bash

# Copyright 2015 Google Inc.
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


# This file changes the permissions of the files and directories.

set -xe

if [ -z "${DOCUMENT_ROOT}" ]; then
    DOCUMENT_ROOT="${APP_DIR}"
fi

# Directories and files we want to protect from the app.
TARGET="${DOCUMENT_ROOT} ${PHP56_DIR} ${PHP70_DIR} ${NGINX_DIR}"

chown -R root.www-data ${TARGET}
chmod -R 0550 ${TARGET}

# Allow nginx to create a runtime files.
chmod 0570 "${NGINX_DIR}" "${NGINX_DIR}/logs"

# Uninstall sudo
env SUDO_FORCE_REMOVE=yes apt-get -qq -y purge sudo > /dev/null 2>&1

# Remove itself
rm -f /change_permissions.sh
