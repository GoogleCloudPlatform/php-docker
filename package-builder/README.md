# Debian Package Builder

This directory contains the code to build all of our debian packages for php and extensions.

## PHP Versions

We currently support the latest patch version of 5.6, 7.0, 7.1, and 7.2. See
[releases](https://github.com/GoogleCloudPlatform/php-docker/releases) for exact versions.

## Extensions

* amqp
* apcu
* apcu_bc
* apm (7.0+)
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
* mongo [deprecated] (5.6)
* mongodb
* oauth
* opencensus
* phalcon
* pq
* raphf
* rdkafka
* redis
* SeasLog
* stackdriver_debugger
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

## Building Packages

1. Install `gcloud` utils.
2. `GOOGLE_PROJECT_ID=my_project_id ./build_packages.sh`

This will use Google Cloud Build to compile packages using docker. The compiled .deb files will be
uploaded to the bucket named `$BUCKET` (defaults to the project id).

If you want to build for specific versions of PHP, set the `$PHP_VERSIONS` environment variable to a comma separated list
of PHP versions. This defaults to a hard-coded list defined in the `build_packages.sh` file

## Adding New Extensions

This folder contains a `new_extension.sh` script to generate the skeleton for
adding support for a new extension.

Example:

```bash
$ ./new_extension.sh
Usage: new_extension.sh <extension name> <upstream maintainer name> <upstream homepage> <package maintainer>

$ ./new_extension.sh grpc "Stanley Cheung <stanleycheung@google.com>" http://pecl.php.net/package/grpc "Jeff Ching <chingor@google.com>"
```

This will generate a folder `extensions/grpc` with the following directory
structure:

```
grpc/
|--- debian/
|    |--- compat
|    |--- control.in
|    |--- copyright
|    |--- ext-grpc.ini
|    |--- gcp-php-grpc.install.in
|    |--- rules.in
|--- build.sh
```

The `build.sh` script is the entrypoint for generating the `.deb` package file
and the `debian` folder contains the necessary packaging configuration.

If the extension requires a development dependency, be sure to add an
`apt-get install -y <dev dependency>` to the `build.sh` file. If the extension
requires a runtime dependency, be sure to add it to the `control.in` file.

You may need to update the license section of the `debian/copyright` file to
match the license of the PHP extension.

You may also need to modify the `build.sh` file to skip builds for unsupported
PHP versions (see libsodium for an example) or to specify an older version (see
mailparse for an example).
