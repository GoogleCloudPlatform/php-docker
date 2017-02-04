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

require_once __DIR__ . '/vendor/autoload.php';

use Symfony\Component\Yaml\Yaml;

class GenFiles
{
    const APP_DIR = '/app';
    const DEFAULT_BASE_IMAGE = 'gcr.io/google-appengine/php';
    const DEFAULT_TAG = 'latest';
    const WORKSPACE = '/workspace';

    private static function readAppYaml()
    {
        return Yaml::parse(file_get_contents(self::WORKSPACE . '/app.yaml'));
    }

    public static function createDockerfile()
    {
        if (file_exists(self::WORKSPACE . '/Dockerfile')) {
            echo 'not creating Dockerfile because the file already exists'
                . PHP_EOL;
            return;
        }
        $docRoot = self::APP_DIR;
        $appYaml = self::readAppYaml();

        if (array_key_exists('runtime_config', $appYaml)
            && array_key_exists('document_root', $appYaml['runtime_config'])) {
            $docRoot = '/app/' . $appYaml['runtime_config']['document_root'];
        }
        $tag = getenv('BUILDER_TARGET_TAG');
        if ($tag === false) {
            $tag = self::DEFAULT_TAG;
        }
        $baseImage = getenv('BUILDER_TARGET_IMAGE');
        if ($baseImage === false) {
            $baseImage = self::DEFAULT_BASE_IMAGE;
        }
        $loader = new Twig_Loader_Filesystem(__DIR__ . '/templates');
        $twig = new Twig_Environment($loader);
        $template = $twig->load('Dockerfile.twig');
        $dockerfile = $template->render(array(
            'base_image' => $baseImage,
            'tag' => $tag,
            'document_root' => $docRoot
        ));
        file_put_contents(self::WORKSPACE . '/Dockerfile', $dockerfile);
    }

    public static function createDockerignore()
    {
        if (file_exists(self::WORKSPACE . '/.dockerignore')) {
            echo 'not creating .dockerignore because the file already exists'
                . PHP_EOL;
            return;
        }
        copy(
            __DIR__ . '/templates/dockerignore.tmpl',
            self::WORKSPACE . '/.dockerignore'
        );
    }
}

GenFiles::createDockerfile();
GenFiles::createDockerignore();
