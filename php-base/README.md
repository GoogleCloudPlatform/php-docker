# Docker base image for PHP

This is a PHP base image for Google Cloud Platform. This image is just
for internal use only. Please look at the derived image in the
`php-onbuild`directory for more details.

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
