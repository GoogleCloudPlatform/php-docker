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
namespace Google\Cloud\tests;

class CustomConfigTest extends \PHPUnit_Framework_TestCase
{
    public function testNginxAdditionalConf()
    {
        exec(
            'docker run php56_custom_configs grep nginx-user.conf '
            . '/etc/nginx/conf.d/nginx-user.conf', $output
        );
        $grep = array_pop($output);
        $this->assertContains('nginx-user.conf', $grep);
    }

    public function testNginxConf()
    {
        exec(
            'docker run php56_custom_configs grep nginx-custom.conf '
            . '/opt/nginx/conf/nginx.conf', $output
        );
        $grep = array_pop($output);
        $this->assertContains('nginx-custom.conf', $grep);
    }

    public function testPhpFpmConf()
    {
        exec(
            'docker run php56_custom_configs grep php-fpm-user.conf '
            . '/opt/php/etc/php-fpm-user.conf', $output
        );
        $grep = array_pop($output);
        $this->assertContains('php-fpm-user.conf', $grep);
    }

    public function testPhpIni()
    {
        exec(
            'docker run php56_custom_configs grep php-user.ini '
            . '/opt/php/lib/conf.d/php-user.ini', $output
        );
        $grep = array_pop($output);
        $this->assertContains('php-user.ini', $grep);
    }

    public function testSupervisordConf()
    {
        exec(
            'docker run php56_custom_configs grep app-supervisord.conf '
            . '/etc/supervisor/conf.d/app-supervisord.conf', $output
        );
        $grep = array_pop($output);
        $this->assertContains('app-supervisord.conf', $grep);
    }
}
