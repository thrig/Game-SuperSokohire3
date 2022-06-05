#!perl
#
# $Id: 40-interface.t,v 1.1 2022/06/05 01:07:20 jmates Exp $

use 5.26.0;
use Test2::V0;

use Game::SuperSokohire3;
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Interface::TestTest123;

my @inputs = (INPUT_BOSS);

sub inh {
    state $i = 0;
    return $inputs[ $i++ ] // INPUT_QUIT;
}

my $io = Game::SuperSokohire3::Interface::TestTest123->new( ifn => \&inh );
isa_ok( $io, 'Game::SuperSokohire3::Interface::TestTest123' );

# TODO game quit/death/victory handling needs some work...
my $okay = eval {
    Game::SuperSokohire3->new(
        delay_seconds => 0.1,
        io            => $io,
        seed          => 0,
    )->run;
    1;
};
isnt( $okay, 1 );
is( $@, "gameover\n" );
is( \%Game::SuperSokohire3::Interface::TestTest123::events,
    {   boss   => 1,
        init   => 1,
        input  => 2,
        quit   => 1,
        title  => 1,
        update => 2,
    }
);

done_testing;
