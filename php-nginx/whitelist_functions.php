<?php

$phpDir = getenv("PHP_DIR");

if ($phpDir === false) {
    exit(0);
}

$whitelist = getenv("WHITELIST_FUNCTIONS");

if ($whitelist === false) {
    exit(0);
} else {
    $whitelist = array_filter(array_map('trim', explode(',', $whitelist)));
}

$disable_functions = ini_get('disable_functions');

// It's tricky, but we still don't have suhosin enabled and we can not fetch
// the list from our suhosin config. Now it defines the list as a literal.
// Note: We need to sync this list with our default suhosin config
// (deb-package-builder/extensions/suhosin/debian/ext-suhosin.ini).
// TODO: Find a better way

$suhosinBlacklist = array('escapeshellarg', 'escapeshellcmd', 'exec',
                          'highlight_file', 'lchgrp', 'lchown', 'link',
                          'symlink', 'passthru', 'pclose', 'popen',
                          'proc_close', 'proc_get_status', 'proc_nice',
                          'proc_open', 'proc_terminate', 'shell_exec',
                          'show_source', 'system', 'gc_collect_cycles',
                          'gc_enable', 'gc_disable', 'gc_enabled', 'getmypid',
                          'getmyuid', 'getmygid', 'getrusage', 'getmyinode',
                          'get_current_user', 'phpinfo', 'phpversion',
                          'php_uname');
$whitelist_ini = '';

$whitelist_ini .= sprintf(
    "suhosin.executor.func.blacklist=\"%s\"\n",
    implode(
        ',',
        array_diff($suhosinBlacklist, $whitelist)
    )
);

if ($disable_functions !== false) {
    $disable_functions = array_filter(
        array_map('trim', explode(',', $disable_functions)));
    $whitelist_ini .= sprintf(
        "disable_functions = \"%s\"\n",
        implode(
            ',',
            array_diff($disable_functions, $whitelist)
        )
    );
}

if ($whitelist_ini !== '') {
    file_put_contents(
        $phpDir . '/lib/conf.d/whitelist_functions.ini',
        $whitelist_ini
    );
}
