# -*- Perl -*-
#
# $Id: Constants.pm,v 1.6 2022/05/13 05:10:07 jmates Exp $
#
# various constants; is exported by Common

package Game::SuperSokohire3::Constants 0.01;
use Exporter 'import';

use constant {
    DIRECTION_EAST  => 0,
    DIRECTION_NORTH => 1,
    DIRECTION_WEST  => 2,
    DIRECTION_SOUTH => 3,
    DIRECTION_MAX   => 4,

    INPUT_NOOP   => -2,
    INPUT_QUIT   => -1,
    INPUT_MOVE_E => 0,
    INPUT_MOVE_N => 1,
    INPUT_MOVE_W => 2,
    INPUT_MOVE_S => 3,
    INPUT_BOSS   => 4,

    WORLD_ROWS => 10,    # LINES, y
    WORLD_COLS => 10,    # COLS, x

    OBJ_EMPTY  => 0,
    OBJ_PLAYER => 1,
    OBJ_THINGY => 2,
    OBJ_WALL   => 3,
};

our @EXPORT = qw(
  DIRECTION_EAST DIRECTION_NORTH DIRECTION_WEST DIRECTION_SOUTH DIRECTION_MAX
  INPUT_NOOP INPUT_QUIT INPUT_BOSS
  INPUT_MOVE_E INPUT_MOVE_N INPUT_MOVE_W INPUT_MOVE_S
  WORLD_ROWS WORLD_COLS
  OBJ_EMPTY OBJ_PLAYER OBJ_THINGY OBJ_WALL
);

1;
__END__
=head1 NAME

Game::SuperSokohire3::Constants - constantly exported

=head1 DESCRIPTION

This module exports various constants for L<Game::SuperSokohire3> into
lots of different modules.

=cut
