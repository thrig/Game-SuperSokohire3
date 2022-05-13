# -*- Perl -*-
#
# $Id: Curses.pm,v 1.8 2022/05/13 05:10:07 jmates Exp $
#
# a Curses-based interface for Game::SuperSokohire3

package Game::SuperSokohire3::Interface::Curses 0.01;
use Object::Pad 0.52;

class Game::SuperSokohire3::Interface::Curses;
use Curses;
use Game::SuperSokohire3::Common;

use constant {
    # PAIRS of colors (the Lojban prefix is to hopefully avoid name
    # clashes with Curses or similar)
    REMEI_WHITE  => 1,
    REMEI_GREY1  => 2,
    REMEI_GREY2  => 3,
    REMEI_GREY3  => 4,
    REMEI_GREY4  => 5,
    REMEI_GREY5  => 6,
    REMEI_GREY6  => 7,
    REMEI_GREY7  => 8,
    REMEI_RED    => 9,
    REMEI_YELLOW => 10,
    REMEI_GREEN  => 11,
    # COLORS - starting above COLOR_WHITE in curses.h
    SKARI_GREY1  => 8,
    SKARI_GREY2  => 9,
    SKARI_GREY3  => 10,
    SKARI_GREY4  => 11,
    SKARI_GREY5  => 12,
    SKARI_GREY6  => 13,
    SKARI_GREY7  => 14,
    SKARI_RED    => 15,
    SKARI_YELLOW => 16,
    SKARI_GREEN  => 17,
    SKARI_WHITE  => 18,
    SKARI_BLACK  => 19,
};

our %ch_inputs = (    # regular keyboard keys (see Curses getch docs)
    B => INPUT_BOSS,
    q => INPUT_QUIT,
    h => INPUT_MOVE_W,
    j => INPUT_MOVE_S,
    k => INPUT_MOVE_N,
    l => INPUT_MOVE_E,
);

our %key_inputs = (    # extended keys (mostly untested)
    260 => INPUT_MOVE_W,
    258 => INPUT_MOVE_S,
    259 => INPUT_MOVE_N,
    261 => INPUT_MOVE_E,
);

has $fancy_colors = 0;
has $map;              # WINDOW* to the $world
has %obj2ch;           # $world object to chtype mapping

########################################################################
#
# METHODS

method init {
    initscr;
    start_color;
    if ( can_change_color and $COLORS >= 256 ) {
        $fancy_colors = 1;
        curses_colors();
        # ascii(7) decimals are used to help Curses see an IV instead of
        # a PV and therefore create the correct chtype. sorry, eh?
        @obj2ch{ OBJ_EMPTY, OBJ_PLAYER, OBJ_THINGY, OBJ_WALL } = (
            46 | COLOR_PAIR(REMEI_GREY3),
            90 | A_BOLD | COLOR_PAIR(REMEI_GREEN),
            120 | COLOR_PAIR(REMEI_YELLOW),
            35 | COLOR_PAIR(REMEI_GREY3)
        );
    } else {
        @obj2ch{ OBJ_EMPTY, OBJ_PLAYER, OBJ_THINGY, OBJ_WALL } =
          ( 46 | A_DIM, 90 | A_BOLD, 120, 35 | A_DIM );
    }

    # disable window resizes: lock $COLS and $LINES to whatever is set
    # just before this handler is added
    $SIG{WINCH} = 'IGNORE';
    # TODO check that window big enough... err how big is that?

    curs_set(0);
    noecho;
    leaveok( $stdscr, 1 );
    keypad(1);    # I guess some people actually use this thing

    $map = newwin( WORLD_ROWS, WORLD_COLS, 1, 1 );
    leaveok( $map, 1 );

    return $self;
}

method input {
    my ( $ch, $key ) = getch;
    if ( defined $key ) {
        return $key_inputs{$key} // INPUT_NOOP;
    } elsif ( defined $ch ) {
        return $ch_inputs{$ch} // INPUT_NOOP;
    }
    return INPUT_NOOP;
}

END { endwin }
method quit { endwin }

# probably not very effective in this era of creepy corporate tracking
method boss {
    # TODO or instead paint some other window then swap back to the game
    # one? how does rogue do the inventory...
    erase;
    nodelay(0);
    getch;
    nodelay(1);
    # TODO redraw the game... call update?
    return $self;
}

method title_screen {
    erase;
    nodelay(0);
    my $offset = int( $LINES / 4 );
    attron( COLOR_PAIR(REMEI_WHITE) ) if $fancy_colors;
    attron(A_BOLD);
    emit_center( "Super Sokohire III: The Legend of the Fall", $offset );
    attroff(A_BOLD);
    emit_center( "-- Press any key --", $offset * 3 );
    attroff( COLOR_PAIR(REMEI_WHITE) ) if $fancy_colors;
    getch;
    erase;
    nodelay(1);
    return $self;
}

method update($game) {
    my $world = $game->world;
    for my $row ( 0 .. WORLD_ROWS - 1 ) {
        for my $col ( 0 .. WORLD_COLS - 1 ) {
            my $obj = $world->[$row][$col];
            addch( $map, $row, $col, $obj2ch{$obj} // 'Q' );
        }
    }
    refresh($map);
    return $self;
}

########################################################################
#
# SUBROUTINES

# we're defining our own primary colors because who knows what the
# terminal has the COLOR_* set to
sub curses_colors {
    # pallete (ncurses uses 0..1000 inclusive for the values; see
    # /usr/src/lib/libcurses/base/lib_color.c as the documentation is
    # not clear as to whether the range is inclusive)
    init_color( SKARI_GREY1,  (125) x 3 );
    init_color( SKARI_GREY2,  (250) x 3 );
    init_color( SKARI_GREY3,  (375) x 3 );
    init_color( SKARI_GREY4,  (500) x 3 );
    init_color( SKARI_GREY5,  (625) x 3 );
    init_color( SKARI_GREY6,  (750) x 3 );
    init_color( SKARI_GREY7,  (875) x 3 );
    init_color( SKARI_RED,    1000, 0,    0 );
    init_color( SKARI_YELLOW, 1000, 1000, 0 );
    init_color( SKARI_GREEN,  0,    1000, 0 );
    init_color( SKARI_WHITE,  1000, 1000, 1000 );
    init_color( SKARI_BLACK,  0,    0,    0 );
    init_pair( REMEI_WHITE, SKARI_WHITE, SKARI_BLACK );
    init_pair( REMEI_GREY1, SKARI_GREY1, SKARI_BLACK );
    init_pair( REMEI_GREY2, SKARI_GREY2, SKARI_BLACK );
    init_pair( REMEI_GREY3, SKARI_GREY3, SKARI_BLACK );
    init_pair( REMEI_GREY4, SKARI_GREY4, SKARI_BLACK );
    init_pair( REMEI_GREY5, SKARI_GREY5, SKARI_BLACK );
    init_pair( REMEI_GREY6, SKARI_GREY6, SKARI_BLACK );
    init_pair( REMEI_GREY7, SKARI_GREY7, SKARI_BLACK );
    init_pair( REMEI_RED,   SKARI_RED,   SKARI_RED );
    # PORTABILITY this may also need A_BOLD on systems where non-bold
    # yellow for some reason actually means brown
    init_pair( REMEI_YELLOW, SKARI_YELLOW, SKARI_BLACK );
    init_pair( REMEI_GREEN,  SKARI_GREEN,  SKARI_BLACK );
}

sub emit_center ( $text, $row = int( $LINES / 2 ) ) {
    my $length = length($text) / 2;
    addstring( $row, int( $COLS / 2 - $length ), $text );
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::Interface::Curses - terminal interface

=head1 DESCRIPTION

This module provides an interface for L<Game::SuperSokohire3> to run
under a terminal.

=cut
