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

use PHPUnit\Framework\TestCase;

require_once(__DIR__ . "/../build-scripts/src/DetectPhpVersion.php");

class DetectPhpVersionTest extends TestCase
{
    const PHP_71 = '7.1.3';
    const AVAILABLE_VERSIONS = [
        self::PHP_71,
    ];

    public function testDetectsPhpVersionFromComposer()
    {
        $version = DetectPhpVersion::versionFromComposer(__DIR__ . '/samples/phalcon.json', self::AVAILABLE_VERSIONS);
        $this->assertEquals(self::PHP_71, $version);
    }

    public function testDetectsHighestVersion()
    {
        $version = DetectPhpVersion::version('^7', self::AVAILABLE_VERSIONS);
        $this->assertEquals(self::PHP_71, $version);
    }

    /**
     * @expectedException \ExactVersionException
     */
    public function testExactVersionDirect()
    {
        $version = DetectPhpVersion::version('7.1.10', self::AVAILABLE_VERSIONS);
    }

    /**
     * @expectedException \InvalidVersionException
     */
    public function testInvalidVersionDirect()
    {
        $version = DetectPhpVersion::version('^7.1.100', self::AVAILABLE_VERSIONS);
    }

    /**
     * @expectedException \ExactVersionException
     */
    public function testExactVersion()
    {
        $version = DetectPhpVersion::versionFromComposer(__DIR__ . '/samples/exact.json', self::AVAILABLE_VERSIONS);
    }

    /**
     * @expectedException \NoSpecifiedVersionException
     */
    public function testNoVersionString()
    {
        $version = DetectPhpVersion::versionFromComposer(__DIR__ . '/samples/no_version.json', self::AVAILABLE_VERSIONS);
    }

    /**
     * @expectedException \InvalidVersionException
     */
    public function testInvalidVersion()
    {
        $version = DetectPhpVersion::versionFromComposer(__DIR__ . '/samples/invalid.json', self::AVAILABLE_VERSIONS);
    }
}
