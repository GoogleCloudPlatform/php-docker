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

FROM python:2.7-alpine

RUN mkdir -p /opt/bin
ENV PATH=${PATH}:/opt/bin:/opt/gcloud/google-cloud-sdk/bin

# Install PHP and tools
RUN apk add php5 php5-openssl php5-json php5-phar php5-dom php5-bcmath wget \
    ca-certificates coreutils unzip --update && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === rtrim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --filename=composer --install-dir=/opt/bin && \
    php -r "unlink('composer-setup.php');" && \
    wget -nv https://phar.phpunit.de/phpunit-5.7.phar && \
    chmod +x phpunit-5.7.phar && \
    mv phpunit.phar /opt/bin/phpunit && \
    wget -nv https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && \
    mkdir -p /opt/gcloud && \
    unzip -qq google-cloud-sdk.zip -d /opt/gcloud && \
    rm google-cloud-sdk.zip && \
    /opt/gcloud/google-cloud-sdk/install.sh --usage-reporting=false \
        --bash-completion=false \
	--disable-installation-options && \
    /opt/gcloud/google-cloud-sdk/bin/gcloud -q components update alpha beta && \
    apk del wget unzip && \
    rm -rf /var/cache/apk/*

COPY run_tests.sh /run_tests.sh
ENTRYPOINT ["/run_tests.sh"]
