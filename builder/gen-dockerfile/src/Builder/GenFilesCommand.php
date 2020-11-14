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

use Google\Cloud\Runtimes\Builder\Exception\EnvConflictException;
use Google\Cloud\Runtimes\Builder\Exception\ExactVersionException;
use Google\Cloud\Runtimes\Builder\Exception\InvalidComposerFlagsException;
use Google\Cloud\Runtimes\Builder\Exception\MissingDocumentRootException;
use Google\Cloud\Runtimes\Builder\Exception\RemovedEnvVarException;
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
    const STACKDRIVER_INTEGRATION_ENV = 'ENABLE_STACKDRIVER_INTEGRATION';
    const REMOVED_ENV_VARS = [
        'COMPOSER_GITHUB_OAUTH_TOKEN'
    ];

    /* @var string */
    private $workspace;

    /* @var array */
    private $appYaml = [];

    /* @var \Twig_Environment */
    private $twig;

    /* @var string */
    private $detectedPhpVersion;

    protected function configure()
    {
        $this
            ->setName('create')
            ->setDescription('Create Dockerfile and .dockerignore file')
            ->addOption(
                'php74-image',
                null,
                InputOption::VALUE_REQUIRED,
                'The PHP 74 base image of the Dockerfile'
            )
            ->addOption(
                'php73-image',
                null,
                InputOption::VALUE_REQUIRED,
                'The PHP 73 base image of the Dockerfile'
            )
            ->addOption(
                'php72-image',
                null,
                InputOption::VALUE_REQUIRED,
                'The PHP 72 base image of the Dockerfile'
            )
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
uses the latest 7.4.x version.
We recommend pinning your PHP version by running:

composer require php 7.4.* (replace it with your desired minor version)

Using PHP version 7.4.x...</info>
");
        } elseif ($version === DetectPhpVersion::EXACT_VERSION_SPECIFIED) {
            throw new ExactVersionException(
                "An exact PHP version was specified in composer.json. Please pin your" .
                "PHP version to a minor version such as '7.4.*'."
            );
        }
        if (substr($version, 0, 3) === '5.6') {
            $this->detectedPhpVersion = '5.6';
        } elseif (substr($version, 0, 3) === '7.0') {
            $this->detectedPhpVersion = '7.0';
        } elseif (substr($version, 0, 3) === '7.1') {
            $this->detectedPhpVersion = '7.1';
        } elseif (substr($version, 0, 3) === '7.2') {
            $this->detectedPhpVersion = '7.2';
        } elseif (substr($version, 0, 3) === '7.3') {
            $this->detectedPhpVersion = '7.3';
        } else {
            $this->detectedPhpVersion = '7.4';
        }
        $yamlPath = getenv('GAE_APPLICATION_YAML_PATH')
            ?: self::DEFAULT_YAML_PATH;
        if (file_exists($this->workspace . '/' . $yamlPath)) {
            $this->appYaml = Yaml::parse(
                file_get_contents($this->workspace . '/' . $yamlPath)
            );
        }
    }

    protected function determineBaseOS()
    {
        $defaultOS = 'debian8';
        $availableOptions = ['debian8', 'ubuntu16'];
        if (!is_array($this->appYaml) || !array_key_exists('runtime_config', $this->appYaml)) {
            return $defaultOS;
        }
        $runtimeConfig = $this->appYaml['runtime_config'];
        $baseOS = (array_key_exists('base_os', $runtimeConfig)
                   && in_array($runtimeConfig['base_os'], $availableOptions))
            ? $runtimeConfig['base_os']
            : $defaultOS;
        return $baseOS;
    }

    protected function determineBaseImage(InputInterface $input, OutputInterface $output)
    {
        $imageOption = 'php'
            . str_replace('.', '', $this->detectedPhpVersion)
            . '-image';
        $baseOS = $this->determineBaseOS();
        if ($baseOS === 'ubuntu16') {
            $imageOption = 'ubuntu-' . $imageOption;
        }
        return $input->getOption($imageOption);
    }
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $this->createDockerfile($this->determineBaseImage($input, $output));
        $this->createDockerignore();
    }

    protected function envsFromAppYaml()
    {
        $ret = array_key_exists('env_variables', $this->appYaml)
            ? $this->appYaml['env_variables']
            : [];
        $removedEnvVars = [];
        foreach (self::REMOVED_ENV_VARS as $k) {
            if (array_key_exists($k, $ret)) {
                $removedEnvVars[] = $k;
            }
        }
        if (count($removedEnvVars) > 0) {
            throw new RemovedEnvVarException(
                "There are environment variables which are no more"
                . "supported. Remove the following keys in "
                . "'env_variables': "
                . implode(" ", $removedEnvVars)
            );
        }
        return $ret;
    }

    protected static function isStackdriverIntegrationEnabled($envs)
    {
        if (array_key_exists(self::STACKDRIVER_INTEGRATION_ENV, $envs)
            && filter_var(
                $envs[self::STACKDRIVER_INTEGRATION_ENV],
                FILTER_VALIDATE_BOOLEAN
            )) {
            return true;
        }
        return false;
    }

    protected function envsFromRuntimeConfig()
    {
        $ret = [];
        if (!is_array($this->appYaml) || !array_key_exists('runtime_config', $this->appYaml)) {
            return $ret;
        }
        $runtimeConfig = $this->appYaml['runtime_config'];
        $envVariables = array_key_exists('env_variables', $this->appYaml)
            ? $this->appYaml['env_variables']
            : [];
        $maps = [
            'builder_debug_output' => 'BUILDER_DEBUG_OUTPUT',
            'composer_flags' => 'COMPOSER_FLAGS',
            'document_root' => 'DOCUMENT_ROOT',
            'enable_stackdriver_integration' => self::STACKDRIVER_INTEGRATION_ENV,
            'front_controller_file' => 'FRONT_CONTROLLER_FILE',
            'nginx_conf_http_include' => 'NGINX_CONF_HTTP_INCLUDE',
            'nginx_conf_include' => 'NGINX_CONF_INCLUDE',
            'nginx_conf_override' => 'NGINX_CONF_OVERRIDE',
            'php_fpm_conf_override' => 'PHP_FPM_CONF_OVERRIDE',
            'php_ini_override' => 'PHP_INI_OVERRIDE',
            'skip_lockdown_document_root' => 'SKIP_LOCKDOWN_DOCUMENT_ROOT',
            'supervisord_conf_addition' => 'SUPERVISORD_CONF_ADDITION',
            'supervisord_conf_override' => 'SUPERVISORD_CONF_OVERRIDE',
            'whitelist_functions' => 'WHITELIST_FUNCTIONS'
        ];
        $errorKeys = [];
        foreach ($maps as $k => $v) {
            if (array_key_exists($k, $runtimeConfig)
                && !empty($runtimeConfig[$k])) {
                // Fail if we find the corresponding values in env_variables.
                if (array_key_exists($v, $envVariables)) {
                    $errorKeys[] = $v;
                }
                if ($v === 'DOCUMENT_ROOT') {
                    if (substr($runtimeConfig[$k], 0, 1) === '/') {
                        // Pass full path as it is.
                        $ret[$v] = $runtimeConfig[$k];
                    } else {
                        // Otherwise prepend the app dir.
                        $ret[$v] = self::APP_DIR . '/' . $runtimeConfig[$k];
                    }
                } elseif ($v === 'BUILDER_DEBUG_OUTPUT'
                          || $v === 'SKIP_LOCKDOWN_DOCUMENT_ROOT') {
                    $ret[$v] = filter_var(
                        $runtimeConfig[$k],
                        FILTER_VALIDATE_BOOLEAN
                    )
                        ? 'true'
                        : 'false';
                } else {
                    $ret[$v] = $runtimeConfig[$k];
                }
            }
        }
        if (count($errorKeys) > 0) {
            throw new EnvConflictException(
                "There are values defined on both 'env_variables' and "
                . "'runtime_config'. Remove the following keys in "
                . "'env_variables': "
                . implode(" ", $errorKeys)
            );
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
                'FRONT_CONTROLLER_FILE' => self::DEFAULT_FRONT_CONTROLLER_FILE,
                // default composer flags for the runtime builder
                'COMPOSER_FLAGS' => '--no-dev --prefer-dist',
                'DETECTED_PHP_VERSION' => $this->detectedPhpVersion
            ];
        // Prevent shell injection with the COMPOSER_FLAGS by only accepting
        // '-', ' ', and alphanumeric characters.
        if (! preg_match('/^[-0-9a-zA-Z ]+$/', $envs['COMPOSER_FLAGS'])) {
            throw new InvalidComposerFlagsException('Invalid COMPOSER_FLAGS');
        }
        // Fail if DOCUMENT_ROOT is not set.
        if (! array_key_exists('DOCUMENT_ROOT', $envs)) {
            throw new MissingDocumentRootException(
                'You have to set document_root in the runtime_config section'
                . ' in app.yaml.'
            );
        }
        if (self::isStackdriverIntegrationEnabled($envs)) {
            $envs['IS_BATCH_DAEMON_RUNNING'] = 'true';
            $enableStackdriverCmd = 'RUN /bin/bash /stackdriver-files/'
                . 'enable_stackdriver_integration.sh';
        } else {
            $enableStackdriverCmd = '';
        }
        $envString = 'ENV ';
        foreach ($envs as $key => $value) {
            $envString .= "$key='$value' \\\n";
        }
        // Remove the last new line and the backslash
        $envString = rtrim($envString, "\n");
        $envString = rtrim($envString, '\\');
        $template = $this->twig->load('Dockerfile.twig');

        $dockerfile = $template->render(array(
            'base_image' => $baseImage,
            'env_string' => $envString,
            'enable_stackdriver_cmd' => $enableStackdriverCmd
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
