<?php
$finder = Symfony\CS\Finder\DefaultFinder::create()
    ->exclude('vendor')
    ->in(__DIR__)
;

return Symfony\CS\Config\Config::create()
    ->level(Symfony\CS\FixerInterface::PSR2_LEVEL)
    ->fixers(array('concat_with_spaces', 'unused_use', 'trailing_spaces', 'indentation'))
    ->finder($finder)
;
