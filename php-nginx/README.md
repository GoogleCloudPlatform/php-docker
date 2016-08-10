# Docker image for the App Engine Flexible PHP runtime with nginx

This is an experimental PHP runtime for Google Cloud App Engine
Flexible Environment. It is not covered by any SLA or deprecation
policy. It may change at any time.

## How to use

This image is intended to use with `runtime: php` configuration. The
image is uploaded to `gcr.io/google_appengine/php:latest`. You can
have your own `app.yaml` as follows:

app.yaml:

```yaml
runtime: php
vm: true
api_version: 1
```

## Disabled functions

These functions are disabled by default:

- `escapeshellarg()` and `escapeshellcmd()`
- `exec()`
- `highlight_file()`
- `lchgrp()`, `lchown()`, `link()`, and `symlink()`
- `passthru()`
- `pclose()` and `popen()`
- `proc_close()`, `proc_get_status()`, `proc_nice()`, `proc_open()`, and `proc_terminate()`
- `shell_exec()`
- `show_source()`
- `system()`
- `gc_collect_cycles()`, `gc_enable()`, `gc_disable()`, and `gc_enabled()`
- `getmypid()`
- `getmyuid()`, and `getmygid()`
- `getrusage()`
- `getmyinode()`
- `get_current_user()`
- `phpinfo()`
- `phpversion()`
- `php_uname()`

These functions are disabled by suhosin extension. The default setting
is as follows:

```ini
suhosin.executor.func.blacklist="escapeshellarg, escapeshellcmd, exec, highlight_file, lchgrp, lchown, link, symlink, passthru, pclose, popen, proc_close, proc_get_status, proc_nice, proc_open, proc_terminate, shell_exec, show_source, system, gc_collect_cycles, gc_enable, gc_disable, gc_enabled, getmypid, getmyuid, getmygid, getrusage, getmyinode, get_current_user, phpinfo, phpversion, php_uname"
```

Additionally, the following functions are also disabled with
`disable_functions` directive:

- `exec`
- `passthru`
- `proc_open`
- `proc_close`
- `shell_exec`
- `show_source`
- `symlink`
- `system`

If you need any of those functions, you can add an environment
variable `WHITELIST_FUNCTIONS`.

app.yaml:

```yaml
runtime: php
vm: true
api_version: 1

env_variables:
  WHITELIST_FUNCTIONS: phpinfo,exec
```

Please remember that allowing one of those makes your attack surface bigger.

## Patched functions

The function `parse_str` is patched and the 2nd parameter is
mandatory.  If you call `parse_str` with only one parameter, it will
throw a warning and nothing happens.

## How to change Document Root (and you should change it)

By default, the document root is `/app`. This means everything will be
served by the web server. You can change the document root by setting
an environment variable `DOCUMENT_ROOT`. You can do it in `Dockerfile`
or `app.yaml`.

Here is an example `Dockerfile` for changing the document root to
`/app/web`.

```Dockerfile
FROM gcr.io/google_appengine/php:latest
ENV DOCUMENT_ROOT /app/web
```

Here is an example `app.yaml` for the same thing (gcloud will turn
this into the envvar):

```yaml
runtime: php
vm: true
api_version: 1

runtime_config:
  document_root: web
```

## How to change nginx.config

An `nginx-app.conf` configuration file is included in the server
section of the main nginx configuration file. The default
configuration file looks like this:

```ini
location / {
  # try to serve files directly, fallback to the front controller
  try_files $uri /index.php$is_args$args;
}
```

To define a custom configuration file, put a file named
`nginx-app.conf` in the project root directory. The runtime will
override the default file with the file you provided.

By default, index.php is used as the framework front controller. You
may need to change this to something different for your project. The
Symfony framework, for instance, uses app.php instead of index.php.

Here is an example `nginx-app.conf` for the Symfony framework:

```ini
location / {
  # try to serve files directly, fallback to the front controller
  try_files $uri /app.php$is_args$args;
}
```

I hope this mechanism can cover most of your use cases, but let us
know if you found otherwise.

## Change the PHP version

You can use `composer` for this purpose. If you want to run your
application with PHP 7.0.0RC6, you can add `php` to your
`composer.json`.

composer.json:

```json
{
    "require": {
        "silex/silex": "^1.3",
        "php": "^7.0"
    },
    "require-dev": {
        "phpunit/phpunit": "~4",
        "symfony/browser-kit": "~2"
    }
}
```

## Extensions

These extensions are enabled as builtin:

- APCu
- Bzip2
- cURL
- FPM
- mcrypt
- MySQL (PDO) (uses mysqlnd)
- MySQLi (uses mysqlnd)
- OPcache
- OpenSSL
- PostgreSQL
- PostgreSQL (PDO)
- Readline
- Sockets
- Zip
- Zlib

These extensions are compiled as shared (you need to enable with
php.ini):

- BCMath (bcmath)
- Calendar (calendar)
- Exif (exif)
- FTP (ftp)
- GD (gd; with PNG, JPEG and FreeType support)
- gettext (gettext)
- intl (intl)
- mbstring (mbstring)
- memcache (shared, experimental support for PHP7)
- memcached (shared, enabled by default, experimental support for PHP7)
- mongodb (shared, experimental support for PHP7)
- MySQL (mysql; it's removed with PHP7.0)
- PCNTL (pcntl)
- redis (shared, experimental support for PHP7)
- Shmop (shmop)
- SOAP (soap)
- SQLite3 (sqlite3)
- SQLite (PDO) (pdo_sqlite)
- XMLRPC (xmlrpc)
- XSL (xsl)

These extensions are only available with PHP 5.6:

- suhosin (shared, but enabled by default)
- gRPC (shared)

These extensions are only available with PHP 7:

- APCu-BC (builtin)

## Add something to php.ini

You can just have php.ini file in your project directory. This file is
added to the main configuration file (See also "How to customize
various config files" below).

## How to customize various config files

There are environment variables for adding config files.

- NGINX_CONF_INCLUDE (defaults to nginx-app.conf)
  This file will be inserted to the main nginx configuration.
- NGINX_CONF_OVERRIDE (defaults to nginx.conf)
  This file will entirely override the main nginx configuration.
- PHP_FPM_CONF_OVERRIDE (defaults to php-fpm.conf)
  Additional config file for php-fpm.
- PHP_INI_OVERRIDE (defaults to php.ini)
  Additional php config file.
- SUPERVISORD_CONF_ADDITION (defaults to additional-supervisord.conf)
  Additional supervisord config file.
- SUPERVISORD_CONF_OVERRIDE (defaults to supervisord.conf)
  The main supervisord config file.

If those files are present, the runtime will copy those files to
appropriate place.

## Use memcached based sessions

If your app is on Google App Engine, we automatically configure the
memcached based session through the [memcache proxy]
(https://cloud.google.com/appengine/docs/managed-vms/custom-runtimes#memcached).

## GitHub oAuth token

If you see messages like `Failed to download vendor/package from dist: Could not
authenticate against github.com`, it means your IP (or effectively the IP of
the ComputeEngine builder VM when you deploy to AppEngine) exceeded the
API rate limit for anonymous access and composer can now only use the
(significantly slower) VCS source method for fetching packages. To fix it,
you can add a environment variable `COMPOSER_GITHUB_OAUTH_TOKEN` to your
deployment (`app.yaml` or `Dockerfile` are both fine).

As this is your personal credential for GitHub, please make sure you do not
commit this token to your repository.

## Reserved TCP port

Nginx and php-fpm are communicating via the TCP port 9000.

## Deploy with gcloud

You can deploy the app by:

```sh
$ gcloud app deploy
```

## Run it locally with docker

You can build the final container image by:

```sh
$ docker build -t myapp .
```

Then you can run the app by:

```sh
$ docker run -p 127.0.0.1:8080:8080 -t -i myapp
```

Note: There is a
[nasty bug in aufs](https://github.com/docker/docker/issues/783). You
may see `Forbidden` error. In such a case, you can switch your
docker's storage backend. Add the following line to
`/etc/default/docker`:

```ini
DOCKER_OPTS="--storage-driver=devicemapper"
```

and restart docker:

```sh
$ sudo service docker restart
```

Then start from building the image.

## Run it locally with PHP's builtin web server

For simple case, you can use the php builtin web server:

```
$ php -S localhost:8080 -t web
```

Note: this doesn't reflect any additional web server configuration.

## Caveats

- To install other extensions, for now you have to do it within your
  Dockerfile. We may utilize [pickle]
  (https://github.com/FriendsOfPHP/pickle) in the future in order to
  provide an easier way to install extensions.
- PHP 7 installation is still missing various extensions including
  suhosin.

## What does this image do

This image does the following:

- Copy everything into `/app` directory.
- Read users' composer.json and if PHP version is specified,
  dynamically change the PHP version.
- Run composer install (`--no-dev --prefer-dist
  --optimize-autoloader`) before running nginx.
- Read the environment variable `DOCUMENT_ROOT` and change `nginx.conf`
  and `php.ini` appropriately
- If there is a file named `nginx.conf` in the project root directory,
  move it to nginx configuration directory, so that the configuration
  file will be completely replaced.
- If there is a file named `nginx-app.conf` in the project root
  directory, move it as an additional configuration file, included in
  the `server` directive of the default main nginx configuration file.
- If there are environment variables for memcached proxy, configure
  the memcached based session.
- Detect the number of processors and configure the number of nginx
  workers. It only works with the default nginx configuration file.
- Then start supervisord.

## Directories and Files in this directory

- build-scripts: Bash scripts to build dependancies from source. By
  isolating builds into multiple pieces we can develop
  quickly. Consider combine them again to minimize the image size when
  we go GA.
- composer.sh: Bash script to dynamically change the runtime PHP
  version and run composer to install app's dependencies.
- detect_php_version.php: PHP script to parse user supplied
  composer.json and detect which PHP version to use.
- Dockerfile: the docker build file.
- entrypoint.sh: a script for entrypoint which will rewrite the
  document root in php.ini and nginx.conf according to the environment
  variable "DOCUMENT_ROOT". It also moves user supplied nginx config
  files to appropriate directory.
- fastcgi_params: the nginx config for processing PHP scripts using a php-fpm
  process.
- gzip_params: the nginx config for gzip compression.
- logrotate.app_engine: the logrotate config for app engine logs.
- nginx.conf: NGINX configuration script - modified from the configuration
  script that is bundled with the nginx package.
- openssl-version-script.patch: Taken from the debian build for OpenSSL, fixes
  issues with "no version information avaialble" when building OpenSSL from
  source. (See http://ubuntuforums.org/showthread.php?t=1905963)
- php-fpm.conf: PHP FPM configuration, originally bundled with the PHP source
  code and modified for the Manage VM/Docker environment.
- php.ini: PHP intiialization file, originally bundled with the PHP source
  code and modified for the Manage VM/Docker environment.
- supervisord.conf: the supervisord config.
