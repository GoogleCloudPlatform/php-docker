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

use Composer\Semver\Semver;

class ExactVersionException extends Exception
{
}

class NoSpecifiedVersionException extends Exception
{
    public function __construct()
    {
        parent::__construct("No version found in composer.json");
    }
}

class InvalidVersionException extends Exception
{
    public function __construct($constraint, $availableVersions)
    {
        $versions = implode(',', $availableVersions);
        parent::__construct("No suitable version for for '$constraint' in $versions");
    }
}

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
        throw new NoSpecifiedVersionException();
    }

    public static function version($constraint, $availableVersions = null)
    {
        if (preg_match('/^\d+\.\d+\.\d+$/', $constraint)) {
            throw new ExactVersionException();
        }

        $availableVersions = $availableVersions ?: self::detectAvailableVersions();
        foreach ($availableVersions as $version) {
            if (Semver::satisfies($version, $constraint)) {
                // The first match wins, picking the highest version possible.
                return $version;
            }
        }
        throw new InvalidVersionException($constraint, $availableVersions);
    }

    private static function detectAvailableVersions()
    {
        return [
            trim(file_get_contents('/opt/php74_version')),
            trim(file_get_contents('/opt/php73_version')),
            trim(file_get_contents('/opt/php72_version')),
            trim(file_get_contents('/opt/php71_version')),
        ];
    }
}
