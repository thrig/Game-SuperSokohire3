# -*- Perl -*-
#
# $Id: Constants.pm,v 1.14 2022/06/14 00:59:43 jmates Exp $
#
# various constants; is exported by Common.pm

package Game::SuperSokohire3::Constants 0.02;
use Exporter 'import';

use constant {
    YY => 0,    # points are generally [y,x] array refs
    XX => 1,

    DIRECTION_EAST  => 0,
    DIRECTION_NORTH => 1,
    DIRECTION_WEST  => 2,
    DIRECTION_SOUTH => 3,

    INPUT_NOPE => -2,
    INPUT_QUIT => -1,
    # directionals
    INPUT_MOVE_E => 0,
    INPUT_MOVE_N => 1,
    INPUT_MOVE_W => 2,
    INPUT_MOVE_S => 3,
    # special
    INPUT_BOSS => 4,
    # modes
    INPUT_ATTACK => 5,
    INPUT_DROP   => 6,
    INPUT_GET    => 7,
    INPUT_MOVE   => 8,
    # some FORTH words for inventory management
    INPUT_ROT  => 9,
    INPUT_SWAP => 10,
    INPUT_TOR  => 11,    # -ROT

    INVENTORY_MAX => 4,  # and you thought that rogue had low limits

    OBJ_VAULTFILL => -2, # for map generation
    OBJ_UNSEEN    => -1, # for map generation
    OBJ_EMPTY     => 0,
    OBJ_PLAYER    => 1,
    OBJ_THINGY    => 2,
    OBJ_WALL      => 3,
    OBJ_CELL      => 4,
    OBJ_DOOR      => 5,
    OBJ_STAIRDOWN => 6,
    OBJ_STAIRUP   => 7,
    OBJ_VOID      => 8,
    MAX_OBJECT    => 9,

    WORLD_ROWS  => 22,    # LINES, y
    WORLD_COLS  => 78,    # COLS, x
    WORLD_DEPTH => 4,     # probably should be deeper
};

our @EXPORT = qw(
  YY XX
  DIRECTION_EAST DIRECTION_NORTH DIRECTION_WEST DIRECTION_SOUTH
  INPUT_NOPE INPUT_QUIT INPUT_BOSS
  INPUT_ATTACK INPUT_DROP INPUT_GET INPUT_MOVE
  INPUT_MOVE_E INPUT_MOVE_N INPUT_MOVE_W INPUT_MOVE_S
  INPUT_ROT INPUT_SWAP INPUT_TOR
  INVENTORY_MAX
  OBJ_VAULTFILL OBJ_UNSEEN OBJ_EMPTY OBJ_PLAYER OBJ_THINGY OBJ_WALL OBJ_CELL
  OBJ_DOOR OBJ_STAIRDOWN OBJ_STAIRUP OBJ_VOID MAX_OBJECT
  WORLD_ROWS WORLD_COLS WORLD_DEPTH
);

1;
__END__
=head1 NAME

Game::SuperSokohire3::Constants - constantly exported

=head1 DESCRIPTION

This module exports various constants for L<Game::SuperSokohire3> into
lots of different modules.

=cut
