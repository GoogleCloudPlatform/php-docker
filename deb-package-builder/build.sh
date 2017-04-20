#!/bin/bash

PHP_VERSIONS='7.1.4-1,7.0.18-1,5.6.30-2'

for VERSION in $(echo ${PHP_VERSIONS} | tr "," "\n")
do
    gcloud container builds submit . --config=cloudbuild.yaml \
                                     --substitutions _PHP_VERSION=${VERSION} \
                                     --timeout=30m
done
