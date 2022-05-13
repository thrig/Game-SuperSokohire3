#!perl
#
# $Id: 00-load.t,v 1.3 2022/05/12 22:34:01 jmates Exp $

use 5.26.0;
use Test2::V0;

my @modules = <<'EOM' =~ m/([A-Z][A-Za-z0-9:]+)/g;
Game::SuperSokohire3::Constants
Game::SuperSokohire3::Common
Game::SuperSokohire3::Interface::Curses
Game::SuperSokohire3
EOM

my $loaded = 0;
for my $m (@modules) {
    local $@;
    eval "require $m";
    if ($@) { bail_out("require failed '$m': $@") }
    $loaded++;
}

diag(
    "Testing Game::SuperSokohire3 $Game::SuperSokohire3::VERSION, Perl $], $^X");
is( $loaded, scalar @modules );
done_testing;
