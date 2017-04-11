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
        'pcntl',
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
        'raphf',
        'rdkafka',
        'redis'
    ];

    private $extensions = [];
    private $missingExtensions = [];
    private $badVersionExtensions = [];
    private $configFile;

    public function __construct($filename, $configFile = null)
    {
        $composer = json_decode(file_get_contents($filename), true);
        if (is_array($composer) && array_key_exists('require', $composer)) {
            foreach ($composer['require'] as $package => $version) {
                if (substr($package, 0, 4) == 'ext-') {
                    $this->addExtension(substr($package, 4), $version);
                }
            }
        }
        $this->configFile = $configFile ?: $this->defaultConfigFile();
    }

    public function extensions()
    {
        return $this->extensions;
    }

    public function missingExtensions()
    {
        return $this->missingExtensions;
    }

    public function badVersionExtensions()
    {
        return $this->badVersionExtensions;
    }

    public function installExtensions()
    {
        if (empty($this->extensions)) {
            return;
        }

        $fp = fopen($this->configFile, 'a');

        echo "Installing extensions...\n";
        foreach ($this->extensions as $extension => $version) {
            echo "Enabling $extension\n";
            fwrite($fp, "extension=$extension.so" . PHP_EOL);
        }

        fclose($fp);
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
        if (in_array($package, self::AVAILABLE_EXTENSIONS)) {
            if ($version == '*') {
                $this->extensions[$package] = $version;
            } else {
                $this->badVersionExtensions[$package] = $version;
            }
        } else {
            $this->missingExtensions[$package] = $version;
        }
    }
}

if (basename($argv[0]) == basename(__FILE__)) {
    if (count($argv) < 2) {
        die("Usage:\n" . $argv[0] . " filename\n");
    }

    $outputFile = count($argv) > 2 ? $argv[2] : null;

    $installer = new InstallExtensions($argv[1], $outputFile);
    if (!empty($installer->missingExtensions()) || !empty($installer->badVersionExtensions())) {
        echo "Failed to install all requested extensions:\n";
        foreach ($installer->missingExtensions() as $extension => $version) {
            echo "- $extension $version is not available on your system.\n";
        }
        foreach ($installer->badVersionExtensions() as $extension => $version) {
            echo "- $extension is available, but version must be specified as \"*\" in your composer.json\n";
        }
        exit(1);
    }
    $installer->installExtensions();
}
