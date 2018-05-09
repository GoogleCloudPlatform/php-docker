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

FROM ${TEST_RUNNER_BASE_IMAGE}

RUN mkdir -p /opt/bin
ENV PATH=${PATH}:/usr/local/bin:/opt/gcloud/google-cloud-sdk/bin

COPY test-runner-php.ini /opt/php/lib/conf.d

# Install PHP and tools
RUN apt-get update && \
    apt-get -y install wget zip && \
    wget -nv -O phpunit.phar https://phar.phpunit.de/phpunit-5.7.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit && \
    wget -nv https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && \
    mkdir -p /opt/gcloud && \
    unzip -qq google-cloud-sdk.zip -d /opt/gcloud && \
    rm google-cloud-sdk.zip && \
    /opt/gcloud/google-cloud-sdk/install.sh --usage-reporting=false \
        --bash-completion=false \
	--disable-installation-options && \
    /opt/gcloud/google-cloud-sdk/bin/gcloud -q components update alpha beta

COPY run_tests.sh /run_tests.sh
ENTRYPOINT ["/run_tests.sh"]
