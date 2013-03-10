#!/usr/bin/perl -w
# -*- perl -*-

use strict;
use Test::More 'no_plan';
use Algorithm::IncludeExclude;

my $aie = Algorithm::IncludeExclude->new;
$aie->include; $aie->exclude('foo', 'bar');
is $aie->evaluate('foo'), 1;
__END__

