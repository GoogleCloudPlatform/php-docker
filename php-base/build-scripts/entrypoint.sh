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


# This file configure the runtime dynamically based on the contents
# and environment variables that user provides.

set -xe

/bin/bash /build-scripts/move-config-files.sh

# Configure memcached based session.
if [ -n "${MEMCACHE_PORT_11211_TCP_ADDR}" ] && [ -n "${MEMCACHE_PORT_11211_TCP_PORT}" ]; then
    cat <<EOF > ${PHP_DIR}/lib/conf.d/memcached-session.ini
session.save_handler=memcached
session.save_path="${MEMCACHE_PORT_11211_TCP_ADDR}:${MEMCACHE_PORT_11211_TCP_PORT}"
EOF
fi

if [ -f "${APP_DIR}/composer.json" ]; then
    # run the composer scripts for post-deploy
    if su www-data -c "php /usr/local/bin/composer --no-ansi run-script -l" \
        | grep -q "post-deploy-cmd"; then
        su www-data -c \
            "php /usr/local/bin/composer run-script post-deploy-cmd \
            --no-ansi \
            --no-interaction" \
            || (echo 'Failed to execute post-deploy-cmd'; exit 1)
    fi
fi

/bin/bash /build-scripts/lockdown.sh

exec "$@"
