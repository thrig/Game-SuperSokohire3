#!perl
#
# $Id: 00-load.t,v 1.8 2022/06/05 04:39:23 jmates Exp $

use 5.26.0;
use Test2::V0;

my @modules = <<'EOM' =~ m/([A-Z][A-Za-z0-9:]+)/g;
Game::SuperSokohire3::Constants
Game::SuperSokohire3::Common
Game::SuperSokohire3::Random
Game::SuperSokohire3::Scrolls
Game::SuperSokohire3::Vaults
Game::SuperSokohire3::Corridors
Game::SuperSokohire3::World
Game::SuperSokohire3::Interface::TestTest123
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
