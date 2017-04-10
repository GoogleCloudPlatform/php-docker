<?php
/**
 * Copyright 2015 Google Inc.
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
require_once __DIR__ . '/vendor/autoload.php';

use Composer\Semver\Semver;

class DetectPhpVersion
{
    public static function versionFromComposer($filename, $availableVersions = null)
    {
        $composer = json_decode(file_get_contents($filename), true);
        if (is_array($composer)
            && array_key_exists('require', $composer)
            && array_key_exists('php', $composer['require'])) {
            $constraints = $composer['require']['php'];
            return self::version($constraints, $availableVersions);
        }
        return '';
    }

    public static function version($constraint, $availableVersions = null)
    {
        $availableVersions = $availableVersions ?: self::detectAvailableVersions();
        foreach ($availableVersions as $version) {
            if (Semver::satisfies($version, $constraint)) {
                // The first match wins, picking the highest version possible.
                return $version;
            }
        }
        return '';
    }

    private static function detectAvailableVersions()
    {
        return [
            getenv('PHP71_VERSION'),
            getenv('PHP70_VERSION'),
            getenv('PHP56_VERSION'),
        ];
    }
}

if (basename($argv[0]) == basename(__FILE__)) {
    if (count($argv) < 2) {
        die("Usage:\n" . $argv[0] . " filename\n");
    }

    $version = DetectPhpVersion::versionFromComposer($argv[1]);

    # only echo out the major/minor
    echo substr($version, 0, strrpos($version, '.'));
}
