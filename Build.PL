# script to set up for installation of IP::World

use strict;
use warnings;
use Module::Build;
use Config;

my @ccflags = ();
my $errwarn = qr/(^|\b)(warning|error)(\b|$)/im;
my $opt;

# test which cc optimize flags are allowed

# move '#' from following line to next line for debugging 
# for my $s ('-g') {  
for my $s ('-O3', '-O2', $Config{'optimize'}) {
    if (!$s) {last}
    $_ = `$Config{'cc'} -c $s test.c 2>&1`;
    if (!/$errwarn/) {
        $opt = $s;
        last;
}   }

# see if this system includes Mmap
$_ = `$Config{'cc'} -c test_mmap.c 2>&1`;
if (!/$errwarn/) {
    push @ccflags, extra_compiler_flags => ["-DMMAPOK"];
}
unlink('test.o', 'test_mmap.o');

my $class = Module::Build->subclass(code => <<'ZZZZ');
    # this is called near the end of the Build step
    sub process_dat_files {
        my $self = shift;
        print "Building database...\n";
        my $result = `scripts/maint_ip_world_db -t 2>&1`;

        # save the output of maint_ip_world_db for the first test program
        if ($result !~ /up-to-date/) {$self->config_data('result' => $result)}
    }
ZZZZ
my $build = $class->new(
    build_requires     => {'ExtUtils::CBuilder' => 0,
                           'Test::More'         => 0},
    configure_requires => {'Config' => 0},
    dist_author        => 'Craig MacKenna <craig@animalhead.com>',
    dynamic_config     => 1,
    license            => 'perl',
    module_name        => 'IP::World',
    requires           => {'perl' => '5.6.1',
                           'Carp' => 0,
                           'File::ShareDir' => 0,
                           'LWP::UserAgent' => 0,
                           'HTTP::Status' => 0,
                           'Time::HiRes' => 0},
    script_files        => 'scripts',
    @ccflags
);
# send the optimize code determined above to the C compoiler
if ($opt) {$build->config(optimize => $opt)}

# this arranges for 'process_dat_files' (and thus maint_ip_world_db) 
#   to be called during the Build step
$build->add_build_element('dat');

# ask whether the user wants maint_ip_world_db to run a command when the DB is updated
my $cmd = $build->prompt(
 "Should the DB-update utility run a command when the DB is updated?\nIf so enter it (if not just return):");

# if so, store the command to run in the config_data structure(s)
if ($cmd) {$build->config_data(cmd => $cmd)}

$build->create_build_script;