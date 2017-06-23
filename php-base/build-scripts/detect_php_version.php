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
        parent::__construct("No suitable version for for '$constraint' in ${implode(',', $availableVersions)}");
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
            trim(file_get_contents('/opt/php71_version')),
            trim(file_get_contents('/opt/php70_version')),
            trim(file_get_contents('/opt/php56_version'))
        ];
    }
}

if (basename($argv[0]) == basename(__FILE__)) {
    if (count($argv) < 2) {
        die("Usage:\n" . $argv[0] . " filename\n");
    }

    try {
        $version = DetectPhpVersion::versionFromComposer($argv[1]);

        # only echo out the major/minor
        echo substr($version, 0, strrpos($version, '.'));
    } catch (ExactVersionException $e) {
        echo 'exact';
    } catch (NoSpecifiedVersionException $e) {
        echo $e->getMessage();
    } catch (InvalidVersionException $e) {
        echo $e->getMessage();
    }
}
