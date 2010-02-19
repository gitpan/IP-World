#!/usr/local/bin/perl

# test to check syntax of the scripts

use strict;
use warnings;
use Test::More tests => 3;
use Module::Build;
use Probe::Perl();

my $perl = Probe::Perl->find_perl_interpreter();

my $build = Module::Build->current();
my $tail = $build->is_unixish() ? ' 2>&1' : '';

# maint_ip_world_db was already run as part of the build step
# we will test its results last

# check syntax of the dump program
#script_compiles ('script/ip_world_dump', "ip_world_dump syntax OK");
my $result = `$perl -c script/ip_world_dump$tail`;
chomp $result;
ok (!($?>>8), $result);

# check syntax of the benchmark program
#script_compiles ('script/ip_cc_benchmark', "ip_cc_benchmark syntax OK");
$result = `$perl -c script/ip_cc_benchmark$tail`;
chomp $result;
ok (!($?>>8), $result);

# check syntax of the maint program
$result = `$perl -c script/maint_ip_world_db$tail`;
chomp $result;
ok (!($?>>8), $result);