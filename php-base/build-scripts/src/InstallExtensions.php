<?php
/**
 * Copyright 2018 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

class InstallExtensions
{
    const AVAILABLE_EXTENSIONS = [
        'bcmath',
        'calendar',
        'exif',
        'ftp',
        'gd',
        'gettext',
        'intl',
        'mbstring',
        'mysql',
        'shmop',
        'soap',
        'sqlite3',
        'pdo_sqlite',
        'xmlrpc',
        'xsl',
        ## Debian package extensions below
        'cassandra',
        'ev',
        'event',
        'grpc',
        'imagick',
        'mailparse',
        'memcache',
        'memcached',
        'mongodb',
        'oauth',
        'opencensus',
        'phalcon',
        'pq',
        'protobuf',
        'raphf',
        'rdkafka',
        'redis',
        'stackdriver_debugger'
    ];
    const AVAILABLE_EXTENSIONS_TO_INSTALL = [
        'amqp',
        'apm',
        'bitset',
        'couchbase',
        'ds',
        'eio',
        'hprose',
        'igbinary',
        'jsond',
        'krb5',
        'lua',
        'lzf',
        'memprof',
        'mongo',
        'seaslog',
        'stomp',
        'swoole',
        'sync',
        'tcpwrap',
        'timezonedb',
        'v8js',
        'vips',
        'yaconf',
        'yaf',
        'yaml'
    ];
    const UNAVAILABLE_EXTENSIONS = [
        'apm' => ['5.6'],
        'couchbase' => ['5.6'],
        'ds' => ['5.6'],
        'lua' => ['5.6'],
        'memcache' => ['7.0', '7.1', '7.2'],
        'mongo' => ['7.0', '7.1', '7.2'],
        'opencensus' => ['5.6'],
        'stackdriver_debugger' => ['5.6'],
        'v8js' => ['5.6'],
        'vips' => ['5.6'],
        'yaconf' => ['5.6']
    ];

    private $extensions = [];
    private $extensionsToInstall = [];
    private $phpVersion;
    private $configFile;
    private $errors = [];

    public function __construct($filename, $configFile = null, $phpVersion = null)
    {
        $this->phpVersion = $phpVersion;
        $this->configFile = $configFile ?: $this->defaultConfigFile();
        $composer = json_decode(file_get_contents($filename), true);
        if (is_array($composer) && array_key_exists('require', $composer)) {
            foreach ($composer['require'] as $package => $version) {
                if (substr($package, 0, 4) == 'ext-') {
                    $this->addExtension(substr($package, 4), $version);
                }
            }
        }
    }

    public function extensions()
    {
        return $this->extensions;
    }

    public function errors()
    {
        return $this->errors;
    }

    public function installExtensions()
    {
        // If there are errors, then bail out
        if (!empty($this->errors)) {
            return false;
        }

        // Nothing to do
        if (empty($this->extensions)) {
            return true;
        }

        // Install any new debian packages
        $this->installPackages();

        // Write a custom php.ini file that enables each extension
        $this->writeConfigFile();

        return true;
    }

    public function packageName($extension)
    {
        return 'gcp-php' . str_replace('.', '', $this->phpVersion) . '-'
            . str_replace('_', '-', $extension);
    }

    private function defaultConfigFile()
    {
        return implode([
            getenv('PHP_DIR'),
            'lib',
            'conf.d',
            'extensions.ini'
        ], '/');
    }

    private function installPackages()
    {
        system('apt-get -y update');
        $command = 'apt-get install -y --no-install-recommends '
            . implode(array_map([$this, 'packageName'], $this->extensionsToInstall), ' ');
        echo $command . PHP_EOL;
        system($command);
    }

    private function writeConfigFile()
    {
        $fp = fopen($this->configFile, 'a');
        foreach ($this->extensions as $extension) {
            fwrite($fp, "extension=$extension.so" . PHP_EOL);
        }
        fclose($fp);
    }

    private function addExtension($package, $version)
    {
        // If it's already loaded, no need for activation
        if (extension_loaded($package)) {
            return;
        }

        // See if we support the package at all
        if (!in_array($package, self::AVAILABLE_EXTENSIONS) &&
            !in_array($package, self::AVAILABLE_EXTENSIONS_TO_INSTALL)) {
            $this->errors[] = "- $package $version is not available on your system.";
            return;
        }

        // Disallow any specific version pinning
        if ($version != '*') {
            $this->errors[] = "- $package is available, but version must be specified as \"*\" in your composer.json";
            return;
        }

        // Check against our blacklist of php version/extension combinations
        if (array_key_exists($package, self::UNAVAILABLE_EXTENSIONS) &&
            in_array($this->phpVersion, self::UNAVAILABLE_EXTENSIONS[$package])) {
            $this->errors[] = "- $package is available, but not on php version {$this->phpVersion}";
            return;
        }

        // We can install this extension
        $this->extensions[] = $package;

        // See if we need to install the debian package
        if (in_array($package, self::AVAILABLE_EXTENSIONS_TO_INSTALL)) {
            $this->extensionsToInstall[] = $package;
        }
    }
}
