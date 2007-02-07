#!/usr/bin/perl
# bad-regex.t 
# Copyright (c) 2007 Jonathan Rockway <jrockway@cpan.org>
use Test::More tests => 4;
use Test::Warn;
use Algorithm::IncludeExclude;

my $IGNORE = ["Ignoring values after a qr// rule"];
my $ie = Algorithm::IncludeExclude->new;
warning_is { $ie->exclude(qr/foo/, 'bar') } $IGNORE;
warning_is { $ie->exclude(qr/foo/, qr/foo/, 'bar') } $IGNORE;
warning_is { $ie->exclude('bar', qr/foo/, 'baz') } $IGNORE;
warning_is { $ie->exclude('bar', qr/foo/, qr/bar/) } $IGNORE;
