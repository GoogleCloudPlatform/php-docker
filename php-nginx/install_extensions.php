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
    const SHARED_EXTENSIONS = [
        'bc',
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
        'xsl'
    ];

    const PACKAGED_EXTENSIONS = [
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
        'rdkafka',
        'redis'
    ];

    private $shared = [];
    private $packaged = [];
    private $configFile;

    public function __construct($filename, $configFile = null)
    {
        $composer = json_decode(file_get_contents($filename), true);
        if (is_array($composer) && array_key_exists('require', $composer)) {
            foreach ($composer['require'] as $package => $version) {
                if (substr($package, 0, 4) == "ext-") {
                    $this->addExtension(substr($package, 4), $version);
                }
            }
        }
        $this->configFile = $configFile ?: $this->defaultConfigFile();
    }

    public function sharedExtensions() {
        return $this->shared;
    }

    public function packagedExtensions() {
        return $this->packaged;
    }

    public function installExtensions()
    {
        if (empty($this->shared)) {
            return;
        }

        $fp = fopen($this->configFile, "a");

        foreach ($this->packaged as $extension => $version) {
            fwrite($fp, "extension=$extension.so" . PHP_EOL);
        }

        foreach ($this->shared as $extension => $version) {
            fwrite($fp, "extension=$extension.so" . PHP_EOL);
        }

        fclose($fp);
    }

    private function defaultConfigFile()
    {
        return implode([
            getenv('PHP_DIR'),
            "conf.d",
            "extensions.ini"
        ], "/");
    }

    private function addExtension($package, $version)
    {

        if (in_array($package, self::SHARED_EXTENSIONS)) {
            $this->shared[$package] = $version;
        } elseif (in_array($package, self::PACKAGED_EXTENSIONS)) {
            $this->packaged[$package] = $version;
        } else {
            echo "didn't find package: $package\n";
        }
    }
}

if ($argv[0] == basename(__FILE__)) {
    if (count($argv) < 2) {
        die("Usage:\n" . $argv[0] . " filename\n");
    }

    $outputFile = count($argv) > 2 ? $argv[2] : null;

    $installer = new InstallExtensions($argv[1], $outputFile);
    $installer->installExtensions();
}
