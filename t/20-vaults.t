#!perl
#
# $Id: 20-vaults.t,v 1.3 2022/06/05 06:21:45 jmates Exp $

use 5.26.0;
use Test2::V0;
use Scalar::Util 'refaddr';

#use Game::SuperSokohire3::Constants;
use Game::SuperSokohire3::Random 'init_jsf';
use Game::SuperSokohire3::Vaults;

my @xx = ( [ 1, 2, 3 ], [ 4, 5, 6 ] );

Game::SuperSokohire3::Vaults::flip_horizontal( \@xx );
is( \@xx, [ [ 4, 5, 6 ], [ 1, 2, 3 ] ] );

Game::SuperSokohire3::Vaults::flip_vertical( \@xx );
is( \@xx, [ [ 6, 5, 4 ], [ 3, 2, 1 ] ] );

my $new;
my @orig = ( [ 1, 2, 3 ], [ 4, 5, 6 ] );
my $yy   = [ [ 1, 2, 3 ], [ 4, 5, 6 ] ];

$new = Game::SuperSokohire3::Vaults::rot0($yy);
is( $new, \@orig );
isnt( refaddr $new, refaddr $yy );

$new = Game::SuperSokohire3::Vaults::rot90($yy);
is( $new, [ [ 3, 6 ], [ 2, 5 ], [ 1, 4 ] ] );
is( $yy,  \@orig );

$new = Game::SuperSokohire3::Vaults::rot180($yy);
is( $new, [ [ 6, 5, 4 ], [ 3, 2, 1 ] ] );
is( $yy,  \@orig );

$new = Game::SuperSokohire3::Vaults::rot270($yy);
is( $new, [ [ 4, 1 ], [ 5, 2 ], [ 6, 3 ] ] );
is( $yy,  \@orig );

init_jsf(0);
my ( $grid, $rows, $cols, $start ) =
  Game::SuperSokohire3::Vaults::create('stairdoor');
# these be index, not array size
is( [ $rows, $cols ], [ 2, 2 ] );

done_testing;
