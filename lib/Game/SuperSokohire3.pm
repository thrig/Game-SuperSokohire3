# -*- Perl -*-
#
# $Id: SuperSokohire3.pm,v 1.19 2022/06/14 00:59:43 jmates Exp $
#
# the game logic, player code, etc

package Game::SuperSokohire3 0.02;
use Object::Pad 0.52;

class Game::SuperSokohire3 :strict(params);
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random 'init_jsf';
use Game::SuperSokohire3::World;
use Syntax::Keyword::Match 0.08 qw(match);
use Time::HiRes 1.77 qw(CLOCK_MONOTONIC clock_gettime sleep);

use constant {
    MOVE_NOPE => 0,
    MOVE_OKAY => 1,
};

has $delay_seconds :param;
has $io            :param;
has $seed          :param;

# y,x coordinate for player
has @hero;
# inventory is a FIFO queue
has $inventory :reader = [];
# is the player moving, attacking, etc? a method reference
has $mode;

# level map is a pointer to something in $world
has $level_map :reader;
has $world = [];

ADJUST {
    init_jsf($seed);

    $mode = \&maybe_move_or_also_push;

    # this should happen before game_loop, and not here!
    $world     = Game::SuperSokohire3::World::generate( $world, 1 );
    $level_map = $world->[0];
    if (0) {
        for my $row ( 0 .. WORLD_ROWS - 1 ) {
            for my $col ( 0 .. WORLD_COLS - 1 ) {
                $level_map->[$row][$col] = OBJ_EMPTY;
            }
        }
        # DBG test test 1 2 3
        $level_map->[6][6]  = OBJ_THINGY;
        $level_map->[7][7]  = OBJ_WALL;
        $level_map->[8][8]  = OBJ_CELL;
        $level_map->[9][9]  = OBJ_DOOR;
        $level_map->[9][10] = OBJ_VOID;
        $level_map->[9][11] = OBJ_STAIRUP;
        $level_map->[9][12] = OBJ_STAIRDOWN;
    }
    @hero = ( 5, 5 );
    $level_map->[ $hero[YY] ][ $hero[XX] ] = OBJ_PLAYER;
}

########################################################################
#
# METHODS

method game_loop {
    # only show these as they become relevant in the game?
    $io->showmode(INPUT_MOVE);
    $io->inventory($inventory);
    $io->update($self);

    while (1) {
        my $input  = $io->input;    # maybe non-blocking, therefore NOPE
        my $result = do {
            match( $input : == ) {
                case (INPUT_NOPE) { MOVE_NOPE }

                # directionals -- 4way 4life
                case (INPUT_MOVE_E) {
                    $self->$mode( [ $hero[YY], ( $hero[XX] + 1 ) % WORLD_COLS ],
                        \@hero, DIRECTION_EAST );
                }
                case (INPUT_MOVE_N) {
                    $self->$mode( [ ( $hero[YY] - 1 ) % WORLD_ROWS, $hero[XX] ],
                        \@hero, DIRECTION_NORTH );
                }
                case (INPUT_MOVE_W) {
                    $self->$mode( [ $hero[YY], ( $hero[XX] - 1 ) % WORLD_COLS ],
                        \@hero, DIRECTION_WEST );
                }
                case (INPUT_MOVE_S) {
                    $self->$mode( [ ( $hero[YY] + 1 ) % WORLD_ROWS, $hero[XX] ],
                        \@hero, DIRECTION_SOUTH );
                }

                # modes
                case (INPUT_ATTACK) {
                    $mode = \&maybe_attack;
                    $io->showmode(INPUT_ATTACK);
                    MOVE_NOPE;
                }
                case (INPUT_DROP) {
                    if (@$inventory) {
                        $mode = \&maybe_drop;
                        $io->showmode(INPUT_DROP);
                    } else {
                        # TODO message here about nothing to drop
                    }
                    MOVE_NOPE;
                }
                case (INPUT_GET) {
                    if ( @$inventory < INVENTORY_MAX ) {
                        $mode = \&maybe_get;
                        $io->showmode(INPUT_GET);
                    } else {
                        # TODO canna pickup any more
                    }
                    MOVE_NOPE;
                }
                case (INPUT_MOVE) {
                    $mode = \&maybe_move_or_also_push;
                    $io->showmode(INPUT_MOVE);
                    MOVE_NOPE;
                }

                # inventory handling (this ain't rogue)
                case (INPUT_ROT) {
                    if ( @$inventory >= 3 ) {
                        unshift @$inventory, splice @$inventory, 2, 1;
                        $io->inventory($inventory);
                        MOVE_OKAY;
                    } else {
                        # TODO underflow message
                        MOVE_NOPE;
                    }
                }
                case (INPUT_SWAP) {
                    if ( @$inventory >= 2 ) {
                        @$inventory[ 0, 1 ] = @$inventory[ 1, 0 ];
                        $io->inventory($inventory);
                        MOVE_OKAY;
                    } else {
                        # TODO underflow message
                        MOVE_NOPE;
                    }
                }
                case (INPUT_TOR) {    # -ROT
                    if ( @$inventory >= 3 ) {
                        splice @$inventory, 2, 0, shift @$inventory;
                        $io->inventory($inventory);
                        MOVE_OKAY;
                    } else {
                        # TODO underflow message
                        MOVE_NOPE;
                    }
                }

                # special keys
                case (INPUT_BOSS) { $io->boss; MOVE_NOPE }
                case (INPUT_QUIT) { $io->quit; exit 1 }
                default {
                    warn "unknown input '$input' ??\n";
                    MOVE_NOPE;
                }
            }
        };
        die "bad result for $input\n" unless defined $result;    # DBG
        if ( $result == MOVE_OKAY ) {
            # monsters and what need to advance here. there's no energy
            # system so everything moves in lockstep by default
            #for my $obj (@$inventory) {
            #}
        }
        $io->update($self);
        refresh_delay($delay_seconds);
    }
}

method maybe_attack( $dst, $src, $direction ) {
    my $obj = $level_map->[ $dst->[YY] ][ $dst->[XX] ];
    match( $obj : == ) {
        case (OBJ_EMPTY) { MOVE_NOPE }
        # TODO need monsters to thwack, eventually
        default { MOVE_NOPE }
    }
}

method maybe_drop( $dst, $src, $direction ) {
    unless (@$inventory) {
        # TODO message here
        $mode = \&maybe_move_or_also_push;
        return MOVE_NOPE;
    }
    my $obj = $level_map->[ $dst->[YY] ][ $dst->[XX] ];
    match( $obj : == ) {
        case (OBJ_EMPTY) {
            $level_map->[ $dst->[YY] ][ $dst->[XX] ] = shift @$inventory;
            $mode = \&maybe_move_or_also_push unless @$inventory;
            $io->inventory($inventory);
            MOVE_OKAY;
        }
        # TODO cells will need to be drop-able
        default { MOVE_NOPE }
    }
}

method maybe_get( $dst, $src, $direction ) {
    if ( @$inventory >= INVENTORY_MAX ) {
        # TODO message about fullness here
        $mode = \&maybe_move_or_also_push;
        return MOVE_NOPE;
    }
    my $obj = $level_map->[ $dst->[YY] ][ $dst->[XX] ];
    match( $obj : == ) {
        case (OBJ_THINGY) {
            unshift @$inventory, OBJ_THINGY;
            $level_map->[ $dst->[YY] ][ $dst->[XX] ] = OBJ_EMPTY;
            $io->inventory($inventory);
            MOVE_OKAY;
        }
        default { MOVE_NOPE }
    }
}

method maybe_move_or_also_push( $dst, $src, $direction ) {
    my @cur    = @$dst;
    my @points = ($src);
  POINT: while (1) {
        my $obj = $level_map->[ $cur[YY] ][ $cur[XX] ];
        match( $obj : == ) {
            case (OBJ_EMPTY) {
                unshift @points, \@cur;
                last POINT;
            }
            case (OBJ_CELL), case (OBJ_VOID), case (OBJ_WALL) {
                return MOVE_NOPE;
            }
            case (OBJ_STAIRDOWN), case (OBJ_STAIRUP) {
                # maybe this could be possible if there's a graph to
                # follow to the next level, but we'll assume there's one
                # of those fire guards that blocks a shove
                return MOVE_NOPE if @points > 1;
                die "todo follow stairs\n";
            }
            case (OBJ_DOOR) {
                # in theory a player with a key might be able to open
                # the door they are pushed into by something else, but
                # we ignore that (or they're too busy getting pushed
                # into to deal with anything about the door)
                return MOVE_NOPE if @points > 1;
                die "todo try open door\n";
            }
            case (OBJ_PLAYER), case (OBJ_THINGY) {
                unshift @points, \@cur;
                @cur = point_to_the( \@cur, $direction );
            }
            case (OBJ_UNSEEN) { return MOVE_NOPE }                # DBG
            default           { die "unknown map object $obj" }
        }
    }
    for my $i ( 0 .. $#points - 1 ) {    # final point is first
        $level_map->[ $points[$i][YY] ][ $points[$i][XX] ] =
          $level_map->[ $points[ $i + 1 ][YY] ][ $points[ $i + 1 ][XX] ];
    }
    $level_map->[ $src->[YY] ][ $src->[XX] ] = OBJ_EMPTY;

    @$src = @$dst;
    return MOVE_OKAY;
}

method run {
    $io->init->title_screen->update($self);
    $self->game_loop;
}

########################################################################
#
# SUBROUTINES

sub point_to_the ( $point, $direction ) {
    my @newpoint = $point->@*;
    match( $direction : == ) {
        case (DIRECTION_EAST)  { $newpoint[XX] = ++$newpoint[XX] % WORLD_COLS }
        case (DIRECTION_NORTH) { $newpoint[YY] = --$newpoint[YY] % WORLD_ROWS }
        case (DIRECTION_WEST)  { $newpoint[XX] = --$newpoint[XX] % WORLD_COLS }
        case (DIRECTION_SOUTH) { $newpoint[YY] = ++$newpoint[YY] % WORLD_ROWS }
        default                { die "unknown direction '$direction'" }
    }
    return @newpoint;
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
