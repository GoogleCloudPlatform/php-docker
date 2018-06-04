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
require_once __DIR__ . '/src/DetectPhpVersion.php';

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
