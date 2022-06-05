#!perl
#
# $Id: 10-random.t,v 1.1 2022/06/04 17:37:24 jmates Exp $
#
# "random" tests. mostly for coverage and that there are not obvious
# problems with the XS

use 5.26.0;
use Test2::V0;

use Game::SuperSokohire3::Random ':all';

init_jsf(42);
is( [ map coinflip, 1 .. 4 ], [ 1, 0, 1, 0 ] );

# destructive pick
init_jsf(0);
my @danlu = qw(mlatu finpe xirma);
is( [ map extract( \@danlu ), 1 .. 4 ], [ qw(xirma finpe mlatu), undef ] );
is( scalar @danlu,                      0 );

init_jsf(0);
is( [ map irand(4), 1 .. 4 ], [ 3, 1, 2, 1 ] );

init_jsf(0);
is( [ map onein(10), 1 .. 10 ], [ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 ] );

# pick is non-destructive extract
init_jsf(0);
@danlu = qw(mlatu finpe xirma);
is( [ map pick( \@danlu ), 1 .. 4 ], [qw(xirma mlatu finpe mlatu)] );
is( scalar @danlu,                   3 );
is( pick( [] ),                      undef );

init_jsf(0);
is( [ map { [ random_point( 4, 4 ) ] } 1 .. 4 ],
    [ [ 3, 1 ], [ 2, 1 ], [ 0, 2 ], [ 1, 2 ] ]
);

init_jsf(0);
# turns (rotate by +90 or -90 degrees) must be adjacent numbers within
# the 0..3 range inclusive
#                                      -1  0  1  2  3  4
is( [ map random_turn($_), -1 .. 4 ], [ 0, 1, 0, 3, 2, 3 ] );

# two handed swords pack a real wallop.
init_jsf(592);
is( roll( 3, 6 ), 18 );

done_testing;
