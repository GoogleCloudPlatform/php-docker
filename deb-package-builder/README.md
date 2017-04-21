# Debian Package Builder

This directory contains the code to build all of our debian packages for php and extensions.

## PHP Versions

We currently support the latest patch version of 5.6, 7.0, and 7.1. See
[releases](https://github.com/GoogleCloudPlatform/php-docker/releases) for exact versions.

## Extensions

* apcu
* apcu_bc
* ev
* event
* gprc
* imagick
* jsonc
* mailparse
* memcache
* memcached
* mongodb
* oauth
* phalcon
* pq
* raphf
* rdkafka
* redis
* suhosin

## Building Packages

1. Install `gcloud` utils.
2. `GOOGLE_PROJECT_ID=my_project_id ./build_packages.sh`

This will use Google Cloud Container Builder to compile packages using docker. The compiled .deb files will be
uploaded to the bucket named `$BUCKET` (defaults to the project id).

If you want to build for specific versions of PHP, set the ``$PHP_VERSIONS` environment variable to a comma separated list
of PHP versions. This defaults to a hard-coded list defined in the `build_packages.sh` file
