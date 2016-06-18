<?php

function filter_blacklist($val)
{
    global $whitelist;
    return !in_array($val, $whitelist);
}

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

$suhosinBlacklist = ini_get('suhosin.executor.func.blacklist');
$disable_functions = ini_get('disable_functions');

$whitelist_ini = '';

if ($suhosinBlacklist !== false) {
    $suhosinBlacklist = array_filter(
        array_map('trim', explode(',', $suhosinBlacklist)));
    $whitelist_ini .= sprintf(
        "suhosin.executor.func.blacklist=\"%s\"\n",
        implode(
            ',',
            array_filter($suhosinBlacklist, 'filter_blacklist')
        )
    );
}

if ($disable_functions !== false) {
    $disable_functions = array_filter(
        array_map('trim', explode(',', $disable_functions)));
    $whitelist_ini .= sprintf(
        "disable_functions = \"%s\"\n",
        implode(
            ',',
            array_filter($disable_functions, 'filter_blacklist')
        )
    );
}

if ($whitelist_ini !== '') {
    file_put_contents(
        $phpDir . '/lib/conf.d/whitelist_functions.ini',
        $whitelist_ini
    );
}
