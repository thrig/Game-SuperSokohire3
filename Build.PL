#!perl
#
# $Id: Build.PL,v 1.8 2022/06/03 13:15:34 jmates Exp $
#
# See the README file for how to build this module.

use 5.26.0;
use warnings;
use Module::Build;
Module::Build->VERSION('0.4004');

my $builder = Module::Build->new(
    module_name        => 'Game::SuperSokohire3',
    dist_author        => 'Jeremy Mates <jeremy.mates@gmail.com>',
    dist_version_from  => 'lib/Game/SuperSokohire3.pm',
    c_source           => 'src',
    create_license     => 0,
    create_readme      => 0,
    dynamic_config     => 0,
    include_dirs       => [qw(. src)],
    license            => 'bsd',
    needs_compiler     => 1,
    release_status     => 'stable',
    configure_requires => {
        'CPAN::Meta'    => '2.142060',
        'Module::Build' => '0.4004',     # test_requires
    },
    requires => {
        # 5.24 is necessary for postderef, and 5.26 for Object::Pad
        # method signatures. has not been tested on perl versions
        # below 5.34
        'perl'                   => '5.26.0',
        'constant'               => 0,
        'strict'                 => 0,
        'Curses'                 => 0,
        'Getopt::Long'           => 0,
        'Import::Base'           => 0,
        'Object::Pad'            => '0.52',
        'Syntax::Keyword::Match' => '0.08',
        'Time::HiRes'            => '1.77',
    },
    test_requires => {
        'Data::Dumper::Concise::Aligned' => 0,    # DBG
        'Test2::V0'                      => 0,
    },
    add_to_cleanup => ['Game-SuperSokohire3-*'],
    auto_features  => {
        dist_authoring => {
            description => "Create new distributions",
            requires    => { 'Archive::Tar' => 1.09, },
        },
    },
);

$builder->create_build_script();
