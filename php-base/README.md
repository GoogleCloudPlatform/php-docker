# Docker base image for PHP

This is a PHP base image for Google Cloud Platform. This image is just
for internal use only. Please look at the derived image in the
`php-onbuild`directory for more details.

## Directories and Files in this directory

- build-scripts: scripts for building the image
- Dockerfile: the docker build file.
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
