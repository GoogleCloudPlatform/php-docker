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

namespace Google\Cloud\Runtimes;

use Composer\Semver\Semver;

class DetectPhpVersion
{
    const NO_PHP_CONSTRAINT_FOUND = 'NO_PHP_CONSTRAINT_FOUND';
    const NO_MATCHED_VERSION_FOUND = 'NO_MATCHED_VERSION_FOUND';
    const EXACT_VERSION_SPECIFIED = 'EXACT_VERSION_SPECIFIED';

    /**
     * Extract the PHP version constraint from the composer file and match
     * against versions we have, then return the first match. If there's no
     * PHP constraint found, it returns NO_PHP_CONSTRAINT_FOUND.
     *
     * @param string $filename A path to the composer.json
     * @param array|null $availableVersions **Defaults to** null.
     *
     * @return string Full version string in the form of x.y.z,
     *         NO_PHP_CONSTRAINT_FOUND, NO_MATCHED_VERSION_FOUND, or EXACT_VERSION_SPECIFIED.
     */
    public static function determinePhpVersionFromComposer(
        $filename,
        $availableVersions = null
    ) {
        if (file_exists($filename)) {
            $composer = json_decode(file_get_contents($filename), true);
            if (is_array($composer)
                && array_key_exists('require', $composer)
                && array_key_exists('php', $composer['require'])) {
                $constraints = $composer['require']['php'];

                if (self::isExactVersion($constraints)) {
                    return self::EXACT_VERSION_SPECIFIED;
                }

                return self::getFirstMatchedVersion(
                    $constraints,
                    $availableVersions
                );
            }
        }
        return self::NO_PHP_CONSTRAINT_FOUND;
    }

    /**
     * Returns the PHP version that matches the given constraint.
     *
     * @param string $constraint
     * @param array|null $availableVersions **Defaults to** null.
     * @return string The full version string, or NO_MATCHED_VERSION_FOUND
     *         when there's no available version.
     */
    public static function getFirstMatchedVersion(
        $constraint,
        $availableVersions = null
    ) {
        $availableVersions = $availableVersions
            ?: self::detectAvailableVersions();
        foreach ($availableVersions as $version) {
            if (Semver::satisfies($version, $constraint)) {
                // The first match wins, so the order matters. Now it's sorted
                // by the version, highest from lowest.
                return $version;
            }
        }
        return self::NO_MATCHED_VERSION_FOUND;
    }

    /**
     * Returns whether the requested PHP version is an exact version constraint.
     *
     * @param string $contraint
     * @return bool Whether or not the constraint is asking for an exact version
     */
    public static function isExactVersion($constraint)
    {
        return !!preg_match('/^\d+\.\d+\.\d+$/', $constraint);
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
