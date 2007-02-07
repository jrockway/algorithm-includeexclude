use inc::Module::Install;

name 'Algorithm-IncludeExclude';
all_from 'lib/Algorithm/IncludeExclude.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

