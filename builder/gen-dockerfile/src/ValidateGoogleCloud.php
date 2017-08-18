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
use Composer\Semver\Comparator;
use Google\Cloud\Runtimes\Builder\Exception\GoogleCloudVersionException;

class ValidateGoogleCloud
{
    const MINIMUM_GOOGLE_CLOUD_VERSION = 'v0.33';
    const MINIMUM_GOOGLE_LOGGING_VERSION = 'v1.3.0';
    const MINIMUM_GOOGLE_ER_VERSION = 'v0.4.0';
    const FOUND_GOOGLE_CLOUD = 1;
    const FOUND_INDIVIDUAL_PACKAGES = 2;

    /*
     * @param string $workspace
     * @return int return FOUND_GOOGLE_CLOUD when we found google/cloud,
     *         otherwise return FOUND_INDIVIDUAL_PACKAGES
     * @throw GoogleCloudVersionException
     */
    public static function doCheck($workspace)
    {
        $filename = $workspace . '/composer.json';
        if (! file_exists($filename)) {
            throw new GoogleCloudVersionException(
                'composer.json does not exist'
            );
        }
        $composer = json_decode(file_get_contents($filename), true);
        $constraintsMap = [];
        $minimumVersionMap = [
            'google/cloud' => self::MINIMUM_GOOGLE_CLOUD_VERSION,
            'google/cloud-logging' => self::MINIMUM_GOOGLE_LOGGING_VERSION,
            'google/cloud-error-reporting' => self::MINIMUM_GOOGLE_ER_VERSION
        ];
        // Make sure there is `require` field in `composer.json`.
        if (!(is_array($composer) && array_key_exists('require', $composer))) {
            throw new GoogleCloudVersionException(
                'Required packages not found in composer.json. '
                . 'Consider running `composer require google/cloud`'
            );
        }
        // For google/cloud.
        if (array_key_exists('google/cloud', $composer['require'])) {
            $constraintsMap['google/cloud'] =
                $composer['require']['google/cloud'];
        } elseif (array_key_exists('google/cloud-logging',
                                   $composer['require']) &&
                  array_key_exists('google/cloud-error-reporting',
                                   $composer['require'])) {
            // For cloud-logging and cloud-error-reporting.
            $constraintsMap['google/cloud-logging'] =
                $composer['require']['google/cloud-logging'];
            $constraintsMap['google/cloud-error-reporting'] =
                $composer['require']['google/cloud-error-reporting'];
        } else {
            throw new GoogleCloudVersionException(
                'Required packages not found in composer.json. '
                . 'Consider running `composer require google/cloud`'
            );
        }

        // Now we have $constraintsMap. All should have at least the minimum
        // version.

        foreach ($constraintsMap as $package => $constraints) {
            $versions = self::getCurrentPackageVersions($package);

            // Check all the available versions against the constraints
            // and returns matched ones
            $filtered = Semver::satisfiedBy($versions, $constraints);
            if (count($filtered) === 0) {
                throw new GoogleCloudVersionException(
                    "no available matching version of $package"
                );
            }
            foreach ($filtered as $version) {
                if (Comparator::lessThan($version, $minimumVersionMap[$package])) {
                    throw new GoogleCloudVersionException(
                        "stackdriver integration needs $package "
                        . $minimumVersionMap[$package] . ' or higher'
                    );
                }
            }
        }

        if (array_key_exists('google/cloud', $constraintsMap)) {
            return self::FOUND_GOOGLE_CLOUD;
        } else {
            return self::FOUND_INDIVIDUAL_PACKAGES;
        }
    }

    /**
     * Determine available versions for a given package.
     * @param string $package
     * @return array
     */
    private static function getCurrentPackageVersions($package)
    {
        exec(
            "composer show --all $package |grep 'versions : '",
            $output,
            $ret
        );
        if ($ret !== 0) {
            throw new GoogleCloudVersionException(
                "Failed to determine available versions of $package package"
            );
        }
        // Remove the title
        $output = substr($output[0], strlen('versions : '));

        // Split the version strings
        $versions = preg_split('/[,\s]+/', $output);

        // Remove '*', indicator for the latest stable
        $versions = array_diff($versions, ['*']);
        return $versions;
    }
}
