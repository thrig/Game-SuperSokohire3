# -*- Perl -*-
#
# $Id: World.pm,v 1.3 2022/06/14 00:59:43 jmates Exp $

package Game::SuperSokohire3::World 0.02;
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random;
use Game::SuperSokohire3::Corridors;
use Game::SuperSokohire3::Vaults;
use Syntax::Keyword::Match 0.08 qw(match);

sub first ( $world, $level, $stash ) {
    # may need larger exitdoor vault so can put the player next to
    # the exit on a known square (or put them somewhere on the first
    # level, with path to the exit)
    my ( $stairs, $rows, $cols, $start ) =
      Game::SuperSokohire3::Vaults::create('exit');

    my ( $my, $mx ) = map { int( $_ / 2 ) } $level->$#*, $level->[0]->$#*;
    for my $vy ( 0 .. $rows ) {
        for my $vx ( 0 .. $cols ) {
            $level->[ $my + $vy ][ $mx + $vx ] = $stairs->[$vy][$vx];
        }
    }
    for my $sp (@$start) {
        $sp->[YY] += $my;
        $sp->[XX] += $mx;
    }

    push @$start, [ 5, 5 ];    # DBG
    Game::SuperSokohire3::Corridors->new(
        map       => $level,
        max_moves => 256,
        start     => $start
    );

    return $level, \&regular;
}

sub generate ( $world, $depth, $stash = {} ) {
    my $gen = \&first;
    for ( 1 .. $depth ) {
        my ( $level, $gen ) = level( $world, $gen, $stash );
        push @$world, $level;
    }
    return $world;
}

sub level ( $world, $details, $stash ) {
    my @level;
    for my $i ( 1 .. WORLD_ROWS ) {
        push @level, [ (OBJ_UNSEEN) x WORLD_COLS ];
    }
    return $details->( $world, \@level, $stash );
}

sub regular ( $world, $level, $stash ) {

    return $level, \&regular;
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::World - world generation

=cut
