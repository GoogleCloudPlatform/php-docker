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
FROM php-nginx

# Move Document root
ENV DOCUMENT_ROOT=/app/web

# Set environment to production
ENV SYMFONY_ENV prod

# Supervisor needs a more lax umask for the php-fpm so the applications'
# front controllers don't need to be modified to use the umask() function.
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Change umask so the application can read and write to var dir
RUN sed -i -e 's/^UMASK *[0-9]*.*/UMASK    002/' /etc/login.defs

# Optimize application state by removing unnecessary classes from the
# autoloader
RUN cd $APP_DIR && $PHP_DIR/bin/php \
    -d suhosin.executor.include.whitelist=phar \
    -d suhosin.executor.func.blacklist=none \
    -d disable_functions= \
    -d memory_limit=-1 \
    -d max_input_time=-1 \
    /usr/local/bin/composer \
    install \
    --prefer-dist \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-ansi \
    --no-progress

# Reset rights on the app directory so we have a clean slate
RUN chown -R www-data:www-data /app
RUN find /app/var -type f -exec chmod 664 {} +
RUN find /app/var -type d -exec chmod 750 {} +
