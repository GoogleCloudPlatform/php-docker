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

namespace Google\Cloud\Runtimes\Builder;

use Google\Cloud\Runtimes\DetectPhpVersion;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Yaml\Yaml;

class GenFilesCommand extends Command
{
    const APP_DIR = '/app';
    const DEFAULT_WORKSPACE = '/workspace';
    const DEFAULT_YAML_PATH = 'app.yaml';
    const DEFAULT_FRONT_CONTROLLER_FILE = 'index.php';

    /* @var string */
    private $workspace;

    /* @var array */
    private $appYaml = [];

    /* @var \Twig_Environment */
    private $twig;

    /* @var string */
    private $baseImage;

    /* @var string */
    private $detectedPhpVersion;

    protected function configure()
    {
        $this
            ->setName('create')
            ->setDescription('Create Dockerfile and .dockerignore file')
            ->addOption(
                'php71-image',
                null,
                InputOption::VALUE_REQUIRED,
                'The PHP 71 base image of the Dockerfile'
            )
            ->addOption(
                'php70-image',
                null,
                InputOption::VALUE_REQUIRED,
                'The PHP 70 base image of the Dockerfile'
            )
            ->addOption(
                'php56-image',
                null,
                InputOption::VALUE_REQUIRED,
                'The PHP 56 base image of the Dockerfile'
            )
            ->addOption(
                'workspace',
                'w',
                InputOption::VALUE_REQUIRED,
                'The directory that contains the app.yaml and artifact output directory'
            );
    }

    protected function initialize(InputInterface $input, OutputInterface $output)
    {
        $loader = new \Twig_Loader_Filesystem(__DIR__ . '/../templates');
        $this->twig = new \Twig_Environment($loader);

        $this->workspace = $input->getOption('workspace')
            ?: getenv('PWD')
            ?: self::DEFAULT_WORKSPACE;
        $version = DetectPhpVersion::determinePhpVersionFromComposer(
            $this->workspace . '/composer.json'
        );
        if ($version === DetectPhpVersion::NO_PHP_CONSTRAINT_FOUND
            || $version === DetectPhpVersion::NO_MATCHED_VERSION_FOUND) {
            $output->writeln("<info>
There is no PHP runtime version specified in composer.json, or
we don't support the version you specified. Google App Engine
uses the latest 7.1.x version.
We recommend pinning your PHP version by running:

composer require php 7.1.* (replace it with your desired minor version)

Using PHP version 7.1.x...</info>
");
        }
        if (substr($version, 0, 3) === '5.6') {
            $this->baseImage = $input->getOption('php56-image');
            $this->detectedPhpVersion = '5.6';
        } elseif (substr($version, 0, 3) === '7.0') {
            $this->baseImage = $input->getOption('php70-image');
            $this->detectedPhpVersion = '7.0';
        } else {
            $this->baseImage = $input->getOption('php71-image');
            $this->detectedPhpVersion = '7.1';
        }
        $yamlPath = getenv('GAE_APPLICATION_YAML_PATH')
            ?: self::DEFAULT_YAML_PATH;
        if (file_exists($this->workspace . '/' . $yamlPath)) {
            $this->appYaml = Yaml::parse(
                file_get_contents($this->workspace . '/' . $yamlPath));
        }
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $this->createDockerfile($this->baseImage);
        $this->createDockerignore();
    }

    protected function envsFromAppYaml()
    {
        return array_key_exists('env_variables', $this->appYaml)
            ? $this->appYaml['env_variables']
            : [];
    }

    protected function envsFromRuntimeConfig()
    {
        $ret = [];
        if (!is_array($this->appYaml) || !array_key_exists('runtime_config', $this->appYaml)) {
            return $ret;
        }
        $runtime_config = $this->appYaml['runtime_config'];

        // TODO: Generalize this process
        if (array_key_exists('whitelist_functions', $runtime_config)) {
            $ret['WHITELIST_FUNCTIONS'] =
                $runtime_config['whitelist_functions'];
        }
        if (array_key_exists('front_controller_file', $runtime_config)
            && !empty($runtime_config['front_controller_file'])) {
            $ret['FRONT_CONTROLLER_FILE'] =
                $runtime_config['front_controller_file'];
        }
        if (array_key_exists('document_root', $runtime_config)
            && !empty($runtime_config['document_root'])) {
            $ret['DOCUMENT_ROOT'] =
                self::APP_DIR . '/' . $runtime_config['document_root'];
        }
        return $ret;
    }

    /**
     * Creates a Dockerfile if it doesn't exist in the workspace.
     */
    public function createDockerfile($baseImage)
    {
        if (file_exists($this->workspace . '/Dockerfile')) {
            echo 'not creating Dockerfile because the file already exists'
                . PHP_EOL;
            return;
        }

        $envs = $this->envsFromRuntimeConfig()
            + $this->envsFromAppYaml()
            + [
                'DOCUMENT_ROOT' => self::APP_DIR,
                'FRONT_CONTROLLER_FILE' => self::DEFAULT_FRONT_CONTROLLER_FILE,
                'GOOGLE_RUNTIME_RUN_COMPOSER_SCRIPT' => 'true',
                'DETECTED_PHP_VERSION' => $this->detectedPhpVersion
            ];
        $envString = 'ENV ';
        foreach ($envs as $key => $value) {
            $envString .= "$key=$value \\\n";
        }
        // Remove the last new line and the backslash
        $envString = rtrim($envString, "\n");
        $envString = rtrim($envString, '\\');
        $template = $this->twig->load('Dockerfile.twig');
        $dockerfile = $template->render(array(
            'base_image' => $baseImage,
            'env_string' => $envString
        ));
        file_put_contents($this->workspace . '/Dockerfile', $dockerfile);
    }

    /**
     * Creates .dockerignore, or adds some lines to an existing one.
     */
    public function createDockerignore()
    {
        $template = $this->twig->load('dockerignore.twig');
        $yamlPath = getenv('GAE_APPLICATION_YAML_PATH')
            ?: self::DEFAULT_YAML_PATH;
        $dockerignore = "\n"
            . $template->render(['app_yaml_path' => $yamlPath]);
        $fp = fopen($this->workspace . '/.dockerignore', 'a');
        fwrite($fp, $dockerignore);
        fclose($fp);
    }
}
