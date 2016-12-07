#!/bin/sh

set -ex

if [ "$#" -eq 0 ]; then
  TEST_DIR='/workspace'
else
  TEST_DIR=${1}
fi
cd ${TEST_DIR}

if [ -f composer.json ]; then
    composer install
fi

phpunit
