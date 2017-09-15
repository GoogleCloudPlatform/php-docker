# Copyright 2017 Google Inc.
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

# Dockerfile for PHP 5.6/7.0/7.1 using nginx as the webserver.

FROM ${PHP_71_IMAGE}

# Allow customizing some composer flags
ONBUILD ARG COMPOSER_FLAGS='--no-scripts --no-dev --prefer-dist'
ONBUILD ENV COMPOSER_FLAGS=${COMPOSER_FLAGS}

# Copy the app and change the owner
ONBUILD COPY . $APP_DIR
ONBUILD RUN chown -R www-data.www-data $APP_DIR

ONBUILD RUN /build-scripts/composer.sh

ENTRYPOINT ["/build-scripts/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
