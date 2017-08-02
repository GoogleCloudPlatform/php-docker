# Debian Package Builder

This directory contains the code to build all of our debian packages for php and extensions.

## PHP Versions

We currently support the latest patch version of 5.6, 7.0, and 7.1. See
[releases](https://github.com/GoogleCloudPlatform/php-docker/releases) for exact versions.

## Extensions

* amqp
* apcu
* apcu_bc
* apm
* couchbase (7.0+)
* ds (7.0+)
* eio
* ev
* event
* gprc
* hprose
* imagick
* jsonc
* jsond
* krb5
* libsodium (7.0, 7.1)
* lua (7.0+)
* LZF
* mailparse
* memcache
* memcached
* memprof
* mongodb
* oauth
* phalcon
* pq
* raphf
* rdkafka
* redis
* SeasLog
* stomp
* suhosin
* swoole
* sync
* tcpwrap
* timezonedb
* v8js (7.0+)
* vips (7.0+)
* yaconf (7.0+)
* yaf
* yaml
* zip

## Building Packages

1. Install `gcloud` utils.
2. `GOOGLE_PROJECT_ID=my_project_id ./build_packages.sh`

This will use Google Cloud Container Builder to compile packages using docker. The compiled .deb files will be
uploaded to the bucket named `$BUCKET` (defaults to the project id).

If you want to build for specific versions of PHP, set the `$PHP_VERSIONS` environment variable to a comma separated list
of PHP versions. This defaults to a hard-coded list defined in the `build_packages.sh` file
