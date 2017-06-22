<?php
/**
 * Copyright 2017 Google Inc.
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
        'phalcon',
        'pq',
        'protobuf',
        'raphf',
        'rdkafka',
        'redis'
    ];
    const UNAVAILABLE_EXTENSIONS = [
        'memcache' => ['7.0', '7.1'],
        'phalcon' => ['7.1']
    ];

    private $extensions = [];
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

        $fp = fopen($this->configFile, 'a');
        foreach ($this->extensions as $extension => $version) {
            fwrite($fp, "extension=$extension.so" . PHP_EOL);
        }
        fclose($fp);

        return true;
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

    private function addExtension($package, $version)
    {
        // See if we support the package at all
        if (!in_array($package, self::AVAILABLE_EXTENSIONS)) {
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
        $this->extensions[$package] = $version;
    }
}

if (basename($argv[0]) == basename(__FILE__)) {
    if (count($argv) < 2) {
        die("Usage:\n" . $argv[0] . " filename\n");
    }

    $outputFile = count($argv) > 2 ? $argv[2] : null;
    $phpVersion = count($argv) > 3 ? $argv[3] : null;

    $installer = new InstallExtensions($argv[1], $outputFile, $phpVersion);
    if (!$installer->installExtensions()) {
        echo "Failed to install all requested extensions:\n";
        foreach ($installer->errors() as $message) {
            echo $message . PHP_EOL;
        }
        exit(1);
    }
}
