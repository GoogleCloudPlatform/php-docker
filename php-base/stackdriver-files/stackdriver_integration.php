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

use Google\Cloud\ErrorReporting\Bootstrap;
use Google\Cloud\Logging\LoggingClient;

/**
 * This class manages detecting whether the Stackdriver integrations will work
 * for the user's application. This class should be loaded in the context of the
 * user's application by requiring the user's composer autoloader.
 */
class StackdriverIntegration
{
    /**
     * We know that for all google-cloud-php releases that have the ErrorReporting
     * bootstrap file, that:
     *
     * 1. the `prependFileLocation()` method exists and reports the correct location
     *  -OR-
     * 2. There exists a `prepend.php` file in the same directory as the
     *    `Bootstrap` class.
     *
     * Any versions of google-cloud-php that do not have the `Bootstrap` class are
     * too low to enable the stackdriver integrations.
     *
     * @return string
     */
    public function prependFileLocation()
    {
        if (!$this->validErrorReportingVersion()) {
            throw new Exception('You must include either google/cloud >= 0.33.0 or google/error-reporting >= 0.4.0');
        }

        if (!$this->validLoggingVersion()) {
            throw new Exception('You must include either google/cloud >= 0.33.0 or google/cloud-logging >= 1.3.0');
        }

        $file = null;
        $reflection = new \ReflectionClass(Bootstrap::class);
        if ($reflection->hasMethod('prependFileLocation')) {
            $file = Bootstrap::prependFileLocation();
        } else {
            // default to same directory as the Bootstrap.php
            $file = realpath(dirname($reflection->getFileName()) . '/prepend.php');
        }

        if (!file_exists($file)) {
            throw new Exception(sprintf('expected file %s to exist', $file));
        }

        return $file;
    }

    /**
     * Returns whether or not the ErrorReporting version is high enough.
     *
     * @return bool
     */
    public function validErrorReportingVersion()
    {
        // Any version that has the `Bootstrap` class is considered high enough
        return class_exists(Bootstrap::class);
    }

    /**
     * Returns whether or not the Logging version is high enough.
     *
     * @return bool
     */
    public function validLoggingVersion()
    {
        if (!class_exists(LoggingClient::class)) {
            return false;
        }
        list($major, $minor, $patch) = explode('.', LoggingClient::VERSION);
        $major = (int) $major;
        $minor = (int) $minor;
        return $major > 1 || ($major == 1 && $minor >= 3);
    }
}
