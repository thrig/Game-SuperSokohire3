# -*- Perl -*-
#
# $Id: SuperSokohire3.pm,v 1.15 2022/06/03 13:15:34 jmates Exp $
#
# the game logic, player code, etc

package Game::SuperSokohire3 0.02;
use Object::Pad 0.52;

class Game::SuperSokohire3 :strict(params);
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random 'init_jsf';
use Time::HiRes 1.77 qw(CLOCK_MONOTONIC clock_gettime sleep);

has $delay_seconds :param;
has $io            :param;     # Interface
has $seed          :param;

has $dirty   = 1;
has $gravity = DIRECTION_SOUTH;
has @hero  :reader;            # y,x coordinate for player
has $world :reader;            # level map

ADJUST {
    init_jsf($seed);
    # TODO instead load up level maps, or procgen them...
    for my $row ( 0 .. WORLD_ROWS - 1 ) {
        for my $col ( 0 .. WORLD_COLS - 1 ) {
            $world->[$row][$col] = OBJ_EMPTY;
        }
    }
    # DBG test test 1 2 3
    $world->[6][6]                   = OBJ_THINGY;
    $world->[7][7]                   = OBJ_WALL;
    $world->[8][8]                   = OBJ_CELL;
    $world->[9][9]                   = OBJ_DOOR;
    @hero                            = ( 5, 5 );
    $world->[ $hero[0] ][ $hero[1] ] = OBJ_PLAYER;
}

########################################################################
#
# METHODS

method affect($point) {
    # fall due to gravity. objects might also activate in other ways?
    while ( defined( my $direction = $self->gravity($point) ) ) {
        my @newp = point_to_the( $point, $direction );
        last unless $self->fallable( \@newp );
        $self->move( \@newp, $point );
        $point = \@newp;
    }
}

method fallable($point) {
    match( $world->[ $point->[0] ][ $point->[1] ] : == ) {
        case (OBJ_EMPTY) { 1 }
        default          { 0 }
    }
}

method game_loop {
    while (1) {
        my ( $direction, @newp );
        my $input = $io->input;
        match( $input : == ) {
            case (INPUT_NOOP) { }
            case (INPUT_MOVE_E) {
                $direction = DIRECTION_EAST;
                @newp      = ( $hero[0], ( $hero[1] + 1 ) % WORLD_COLS );
            }
            case (INPUT_MOVE_N) {
                $direction = DIRECTION_NORTH;
                @newp      = ( ( $hero[0] - 1 ) % WORLD_ROWS, $hero[1] );
            }
            case (INPUT_MOVE_W) {
                $direction = DIRECTION_WEST;
                @newp      = ( $hero[0], ( $hero[1] - 1 ) % WORLD_COLS );
            }
            case (INPUT_MOVE_S) {
                $direction = DIRECTION_SOUTH;
                @newp      = ( ( $hero[0] + 1 ) % WORLD_ROWS, $hero[1] );
            }
            case (INPUT_BOSS) { $io->boss; $dirty = 1 }
            case (INPUT_QUIT) { $io->quit; exit 1 }
            default           { warn "unknown input '$input' ??\n" }
        }
        if (@newp) {
            my ( $ok, $point ) = $self->move_okay( \@newp, \@hero, $direction );
            if ($ok) {
                $self->move( \@newp, \@hero );
                @hero = @newp;
            }
            # player touching objects (or certain locations) causes them
            # to activate
            $self->affect($point) if $point;
        }
        # TODO may also need a world update somewhere, maybe here
        if ($dirty) {
            $io->update($self);
            $dirty = 0;
        }
        refresh_delay($delay_seconds);
    }
}

method gravity($point) {
    match( $gravity : == ) {
        case (DIRECTION_EAST) {
            $point->[1] < WORLD_COLS - 1 ? DIRECTION_EAST : undef;
        }
        case (DIRECTION_NORTH) {
            $point->[0] > 0 ? DIRECTION_NORTH : undef
        }
        case (DIRECTION_WEST) {
            $point->[1] > 0 ? DIRECTION_WEST : undef;
        }
        case (DIRECTION_SOUTH) {
            $point->[0] < WORLD_ROWS - 1 ? DIRECTION_SOUTH : undef;
        }
        default { die "unknown gravity '$gravity'" }
    }
}

method move( $dst, $src ) {
    # TODO must animate the falling. notify $io somehow?
    my $obj = $world->[ $src->[0] ][ $src->[1] ];
    # TODO need way to "put back" non-EMPTY things that yet can be
    # walked over by monsters
    $world->[ $src->[0] ][ $src->[1] ] = OBJ_EMPTY;
    $world->[ $dst->[0] ][ $dst->[1] ] = $obj;
    $dirty                             = 1;
}

# TODO may want interactions, like if a resource falls onto player
# that's like picking it up...
method move_okay( $dst, $src, $direction ) {
    my ( $ret, $point );
    my $obj = $world->[ $dst->[0] ][ $dst->[1] ];
    match( $obj : == ) {
        case (OBJ_EMPTY) { $ret = 1 }
        case (OBJ_PLAYER), case (OBJ_WALL), case (OBJ_DOOR), case (OBJ_CELL) { }
        case (OBJ_THINGY) {
            # can it be pushed?
            my @newp = point_to_the( $dst, $direction );
            my ($ok) = $self->move_okay( \@newp, $dst, $direction );
            if ($ok) {
                $self->move( \@newp, $dst );
                ( $ret, $point ) = ( $ok, \@newp );
            } else {
                if ( $world->[ $src->[0] ][ $src->[1] ] == OBJ_PLAYER ) {
                    # TODO increase score or put in player inventory
                    ( $ret, $point ) = ( 1, undef );
                } else {
                    ( $ret, $point ) = ( 0, $dst );
                }
            }
        }
        default { die "unknown map object '$obj' at @$dst" }
    }
    return $ret, $point;
}

method run {
    $io->init->title_screen->update($self);
    $self->game_loop;
}

########################################################################
#
# SUBROUTINES

sub point_to_the ( $point, $direction ) {
    my @newp = $point->@*;
    match( $direction : == ) {
        case (DIRECTION_EAST)  { $newp[1] = ++$newp[1] % WORLD_COLS }
        case (DIRECTION_NORTH) { $newp[0] = --$newp[0] % WORLD_ROWS }
        case (DIRECTION_WEST)  { $newp[1] = --$newp[1] % WORLD_COLS }
        case (DIRECTION_SOUTH) { $newp[0] = ++$newp[0] % WORLD_ROWS }
        default                { die "unknown direction '$direction'" }
    }
    return @newp;
}

sub refresh_delay ($refresh) {
    state $mark  = clock_gettime(CLOCK_MONOTONIC);
    state $extra = 0;

    my $delay = $refresh - ( clock_gettime(CLOCK_MONOTONIC) - $mark ) - $extra;
    if ( $delay > 0 ) {
        $extra = sleep($delay) - $refresh;
        $extra = 0 if $extra < 0;
    }
    $mark = clock_gettime(CLOCK_MONOTONIC);
}

1;
__END__
=head1 NAME

Game::SuperSokohire3 - The great new Game::SuperSokohire3!

=head1 SYNOPSIS

  supersokohire3

should be run from the command line.

=head1 DESCRIPTION

Can you restore the Fourth Algolnoid Empire through righteous
statecraft? (But the game is totally not yet playable.)

=head1 COPYRIGHT & LICENSE

Copyright 2022 Jeremy Mates, All Rights Reserved.

This program is distributed under the (Revised) BSD License:
L<https://opensource.org/licenses/BSD-3-Clause>

The C<src/jsf.*> code appears to be under a "I wrote this PRNG. I place
it in the public domain." license:

L<http://burtleburtle.net/bob/rand/smallprng.html>

=cut
