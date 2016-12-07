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

# Dockerfile for running phpunit within a cloudbuild step.

FROM alpine

RUN mkdir -p /opt/bin
ENV PATH=${PATH}:/opt/bin

# Install PHP and tools
RUN apk add php5 php5-openssl php5-json php5-phar php5-dom php5-bcmath wget \
    ca-certificates coreutils --update \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --filename=composer --install-dir=/opt/bin \
    && php -r "unlink('composer-setup.php');" \
    && wget https://phar.phpunit.de/phpunit.phar \
    && chmod +x phpunit.phar \
    && mv phpunit.phar /opt/bin/phpunit \
    && apk del wget \
    && rm -rf /var/cache/apk/*

COPY run_tests.sh /run_tests.sh
ENTRYPOINT ["/run_tests.sh"]
