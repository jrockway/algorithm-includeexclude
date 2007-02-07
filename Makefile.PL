use inc::Module::Install;
use strict;
use warnings;

name 'Algorithm-IncludeExclude';
all_from 'lib/Algorithm/IncludeExclude.pm';
build_requires 'Test::More';
auto_install;
WriteAll;
