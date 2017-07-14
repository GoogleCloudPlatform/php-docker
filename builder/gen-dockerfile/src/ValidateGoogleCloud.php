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
    const MINIMUM_VERSION = 'v0.33';

    /*
     * @param string $workspace
     * @return bool
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
        if (is_array($composer)
            && array_key_exists('require', $composer)
            && array_key_exists('google/cloud', $composer['require'])) {
            $constraints = $composer['require']['google/cloud'];
        } else {
            throw new GoogleCloudVersionException(
                'google/cloud not found in composer.json'
            );
        }

        $versions = self::getCurrentGoogleCloudVersions();

        // Check all the available versions against the constraints
        // and returns matched ones
        $filtered = Semver::satisfiedBy($versions, $constraints);

        if (count($filtered) === 0) {
            throw new GoogleCloudVersionException(
                'no available matching version of google/cloud'
            );
        }
        foreach ($filtered as $version) {
            if (Comparator::lessThan($version, self::MINIMUM_VERSION)) {
                throw new GoogleCloudVersionException(
                    'stackdriver integration needs google/cloud '
                    . self::MINIMUM_VERSION . ' or higher'
                );
            }
        }
        return true;
    }

    /**
     * Determine available versions for google/cloud
     * @return array
     */
    private static function getCurrentGoogleCloudVersions()
    {
        exec(
            'composer show --all google/cloud |grep \'versions : \'',
            $output,
            $ret
        );
        if ($ret !== 0) {
            throw new GoogleCloudVersionException(
                'Failed to determine available versions of google/cloud package'
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
