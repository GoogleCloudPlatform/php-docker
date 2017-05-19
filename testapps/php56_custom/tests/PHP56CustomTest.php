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

use GuzzleHttp\Client;

class PHP56CustomTest extends \PHPUnit_Framework_TestCase
{
    private $client;

    private static $extensions = array(
        # static
        'date',
        'libxml',
        'openssl',
        'pcre',
        'zlib',
        'apc',
        'apcu',
        'bz2',
        'ctype',
        'curl',
        'dom',
        'fileinfo',
        'filter',
        'hash',
        'iconv',
        'json',
        'mailparse',
        'mcrypt',
        'SPL',
        'session',
        'PDO',
        'standard',
        'pdo_pgsql',
        'pgsql',
        'Phar',
        'posix',
        'readline',
        'recode',
        'Reflection',
        'mysqlnd',
        'SimpleXML',
        'sockets',
        'pdo_mysql',
        'mysqli',
        'tokenizer',
        'xml',
        'xmlreader',
        'xmlwriter',
        'zip',
        'cgi-fcgi',
        # shared
        'bcmath',
        'calendar',
        'exif',
        'ftp',
        'gd',
        'gettext',
        'intl',
        'mbstring',
        'memcache',
        'memcached',
        'mysql',
        'pcntl',
        'redis',
        'shmop',
        'soap',
        'sqlite3',
        'pdo_sqlite',
        'xmlrpc',
        'xsl',
        'mongodb',
        'imagick',
        # Both are gone with PHP 7.
        'ereg',
        'mysql',
        # Only available for PHP < 7 right now.
        'suhosin',
        'grpc',
    );

    public static function setUpBeforeClass()
    {
        // Wait for nginx to start
        sleep(3);
        // For a test for long running requests
        ini_set("default_socket_timeout", 70);
    }

    public function setUp()
    {
        $this->client = new Client(['base_uri' => 'http://php56-custom:8080/']);
    }

    public function testDefaultFile()
    {
        // Index serves succesfully with 'Hello World'.
        // This works because the custom DOCUMENT_ROOT is working.
        $resp = $this->client->get('');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'index.php status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());
    }

    public function testDotFile()
    {
        $this->setExpectedException('\GuzzleHttp\Exception\ClientException');
        $resp = $this->client->get('.test');
    }

    public function testBackupFile()
    {
        $this->setExpectedException('\GuzzleHttp\Exception\ClientException');
        $resp = $this->client->get('index.php~');
    }

    public function testIndex()
    {
        // Index serves succesfully with 'Hello World'.
        // This works because the custom DOCUMENT_ROOT is working.
        $resp = $this->client->get('index.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'index.php status code');
        $this->assertContains('Hello World', $resp->getBody()->getContents());
    }

    public function testGoodbye()
    {
        // The URL '/goodbye' works with 'Goodbye World'.
        // This works because the nginx-app.conf is effective.
        $resp = $this->client->get('/goodbye');
        $this->assertEquals('200', $resp->getStatusCode(),
                            '/goodbye status code');
        $this->assertContains('Goodbye World',
                              $resp->getBody()->getContents());
    }

    public function testPhpInfo()
    {
        // Access to phpinfo.php, while phpinfo() is disabled with the custom
        // php.ini.
        $resp = $this->client->get('phpinfo.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'phpinfo.php status code');
        $this->assertEquals('', $resp->getBody()->getContents(),
                            'phpinfo() should be disabled and the content'
                            . ' should be empty.');
    }

    public function testExec()
    {
        // Access to exec.php; exec() should be enabled.
        $resp = $this->client->get('exec.php');
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'exec.php status code'
        );
        $this->assertContains(
            'exec succeeded.',
            $resp->getBody()->getContents()
        );
    }

    public function testPdoSqlite()
    {
        // Access to pdo_sqlite.php, which should work.
        $resp = $this->client->get('pdo_sqlite.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'pdo_sqlite.php status code');
        $this->assertContains('Hello pdo_sqlite',
                              $resp->getBody()->getContents());
    }

    public function testNumberOfPhpFpmChildren()
    {
        $resp = $this->client->get('php-fpm-count.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'php-fpm-count.php status code');
        $this->assertEquals(
            2,
            intval($resp->getBody()->getContents()),
            'There should be only 2 php-fpm processes, actual: '
            . $resp->getBody()->getContents()
        );
    }

    public function testNumberOfNginxChildren()
    {
        exec('nproc', $nproc);
        $resp = $this->client->get('nginx-count.php');
        $this->assertEquals('200', $resp->getStatusCode(),
                            'nginx-count.php status code');
        $count = intval($resp->getBody()->getContents());
        $this->assertGreaterThan(
            $nproc[0], $count,
            "There should be more than $nproc[0] nginx processes, actual: $count"
        );
    }

    public function testParseStrIsSafe()
    {
        // Access to parse_str.php and make sure it doesn't override global
        // variables.
        $resp = $this->client->get('parse_str.php');
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'parse_str.php status code'
        );
        $this->assertContains(
            'This is an important variable',
            $resp->getBody()->getContents()
        );
    }

    public function testSleep()
    {
        // Test for a long running request.
        $resp = $this->client->get('sleep');
        $this->assertEquals('200', $resp->getStatusCode(), 'sleep status code');
        $this->assertContains(
            'Slept 61 seconds',
            $resp->getBody()->getContents()
        );
    }

    public function testInteractiveOutput()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('../callable_output.txt')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'The script is not interactive!',
            $resp->getBody()->getContents()
        );
    }

    public function testPhpCliIni()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('../cli-ini-test.txt')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'shell_exec succeeded',
            $resp->getBody()->getContents()
        );
    }

    public function testCommandOutput()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('../script_output.txt')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            'Testing Post Deploy Command',
            $resp->getBody()->getContents()
        );
    }

    public function testNginxHttpConf()
    {
        $resp = $this->client->get(
            'readfile.php?f=' . urlencode('/etc/nginx/conf.d/nginx-http.conf')
        );
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'readfile status code'
        );
        $this->assertContains(
            '# nginx-http.conf',
            $resp->getBody()->getContents()
        );
    }

    public function testFilePermissions()
    {
        $resp = $this->client->get('permission.php');
        $this->assertEquals(
            '200',
            $resp->getStatusCode(),
            'permission status code'
        );
        $this->assertContains('777', $resp->getBody()->getContents());
    }

    public function testExtensions()
    {
        $resp = $this->client->get('extensions.php');
        $loaded = $resp->getBody()->getContents();
        foreach (self::$extensions as $ext) {
            $this->assertContains($ext, $loaded);
        }
    }

    public function testImagickCanLoad()
    {
        $resp = $this->client->get('imagick.php');
        $body = $resp->getBody()->getContents();

        // test image should by 300px by 1px
        $this->assertContains('300x1', $body);
    }
}
