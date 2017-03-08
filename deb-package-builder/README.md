# Debian Package Builder

This directory contains the code to build all of our debian packages for php and extensions.

## PHP Versions

We currently support the latest patch version of 5.6, 7.0, and 7.1. See
[releases](https://github.com/GoogleCloudPlatform/php-docker/releases) for exact versions.

## Extensions

* apcu
* apcu_bc
* gprc
* imagick
* jsonc
* mailparse
* memcache
* memcached
* mongodb
* phalcon
* redis
* suhosin

## Building Packages

```bash
$ docker build . -t debian_package_builder_php
$ docker run --rm -v /path/to/output/directory:/workspace debian_package_builder_php <VERSIONS> [EXTENSIONS]
```

VERSIONS is a comma-separated list of php versions.

EXTENSIONS is an optional comma-separated list of extension names. If not provided we will build all extensions.

Example:

```bash
docker run --rm -v /tmp:/workspace debian_package_builder_php 7.1.2-2,7.0.16-2,5.6.30-2 jsonc,phalcon
```

The builder compiles all of the extensions in a working directory, then copies the .deb artifact to the `/workspace`
directory. If you do not mount a local volume into the container, then you will not see your build packages.
