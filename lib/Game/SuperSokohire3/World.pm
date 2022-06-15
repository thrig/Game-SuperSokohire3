# -*- Perl -*-
#
# $Id: World.pm,v 1.6 2022/06/14 21:50:53 jmates Exp $

package Game::SuperSokohire3::World 0.02;
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random qw(pick random_point);
use Game::SuperSokohire3::Corridors;
use Game::SuperSokohire3::Vaults;
use Syntax::Keyword::Match 0.08 qw(match);

# this level needs an exit stair vault, at least
sub first ( $game, $level_map, $zlevel, $features ) {
    my ( $grid, $rows, $cols, $start, $meta ) = make_vault('exit');

    # this may need more padding to keep it away from the edge of
    # the map
    my ( $max_row, $max_col ) = ( $level_map->$#*, $level_map->[0]->$#* );
    my ( $my, $mx ) = random_point( $max_row + 1 - $rows, $max_col + 1 - $cols );
    $my += $rows;
    $mx += $cols;
    for my $vy ( 0 .. $rows ) {
        for my $vx ( 0 .. $cols ) {
            my $obj = $grid->[$vy][$vx];
            if ( $obj == OBJ_STAIRUP ) {
                my $fkey = join '.', $my + $vy, $mx + $vx, $zlevel;
                $features->{$fkey} = 'victory';
            } elsif ( $obj == OBJ_DOOR ) {
                # TODO door handling code... for now DBG open it up
                $obj = OBJ_EMPTY;
            }
            $level_map->[ $my + $vy ][ $mx + $vx ] = $obj;
        }
    }
    for my $sp (@$start) {
        $sp->[YY] += $my;
        $sp->[XX] += $mx;
    }

    my $corr = Game::SuperSokohire3::Corridors->new(
        map       => $level_map,
        max_moves => int( 0.2 * WORLD_ROWS * WORLD_COLS ),
        start     => $start
    );

    my @hero = pick( $corr->carved )->@*;
    $game->hero->@* = @hero;
    $level_map->[ $hero[YY] ][ $hero[XX] ] = OBJ_PLAYER;

    for my $y ( 0 .. $max_row ) {
        for my $x ( 0 .. $max_col ) {
            $level_map->[$y][$x] = OBJ_WALL if $level_map->[$y][$x] < 0;
        }
    }

    return $level_map, \&regular;
}

sub generate ( $game, $world, $depth, $features ) {
    my $genfn = \&first;
    for my $z ( 0 .. $depth - 1 ) {
        my ( $level_map, $gen ) = make_level( $game, $genfn, $z, $features );
        push @$world, $level_map;
    }
}

sub make_level ( $game, $genfn, $zlevel, $features ) {
    my @map;
    for ( 1 .. WORLD_ROWS ) { push @map, [ (OBJ_UNSEEN) x WORLD_COLS ] }
    return $genfn->( $game, \@map, $zlevel, $features );
}

sub regular ( $game, $level_map, $zlevel, $features ) {
    # TODO
    return $level_map, \&regular;
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::World - world generation

=cut
