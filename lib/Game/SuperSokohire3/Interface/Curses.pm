# -*- Perl -*-
#
# $Id: Curses.pm,v 1.17 2022/06/05 13:22:17 jmates Exp $
#
# a Curses-based interface for Game::SuperSokohire3

package Game::SuperSokohire3::Interface::Curses 0.02;
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

our $bosswin;

our %ch_inputs = (    # regular keyboard keys (see Curses getchar docs)
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

# ascii(7) decimals are used to help Curses see an IV instead of a PV
# and therefore create the correct chtype. sorry, eh?
our %boring = (
    OBJ_EMPTY, 46, OBJ_PLAYER,    64, OBJ_THINGY,  120,
    OBJ_WALL,  35, OBJ_CELL,      95, OBJ_DOOR,    43,
    OBJ_VOID,  32, OBJ_STAIRDOWN, 62, OBJ_STAIRUP, 60,
);
our %fancy = (
    OBJ_EMPTY,     46 | COLOR_PAIR(REMEI_GREY3),
    OBJ_PLAYER,    64 | A_BOLD | COLOR_PAIR(REMEI_GREEN),
    OBJ_THINGY,    120 | COLOR_PAIR(REMEI_YELLOW),
    OBJ_WALL,      35 | COLOR_PAIR(REMEI_GREY7),
    OBJ_CELL,      95 | COLOR_PAIR(REMEI_WHITE),
    OBJ_DOOR,      43 | COLOR_PAIR(REMEI_WHITE),
    OBJ_VOID,      32,    # void may need a lighter background?
    OBJ_STAIRDOWN, 62 | COLOR_PAIR(REMEI_WHITE),
    OBJ_STAIRUP,   60 | COLOR_PAIR(REMEI_WHITE),
);

########################################################################
#
# METHODS

method init {
    initscr;
    start_color;
    if ( can_change_color and $COLORS >= 256 ) {
        setup_curses_colors();
        %obj2ch       = %fancy;
        $fancy_colors = 1;
    } else {
        %obj2ch = %boring;
    }
    # DBG have we probably mapped everything?
    if ( keys %obj2ch != MAX_OBJECT ) {
        die "error: possibly unhandled objects (fancy=$fancy_colors)\n";
    }

    # disable window resizes: lock $COLS and $LINES to whatever is set
    # just before this handler is added
    $SIG{WINCH} = 'IGNORE';
    # TODO check that window big enough... err how big is that?

    curs_set(0);
    noecho;
    leaveok( $stdscr, 1 );
    keypad(1);    # I guess some people actually have and use this

    $map = newwin( WORLD_ROWS, WORLD_COLS, 1, 1 );
    leaveok( $map, 1 );

    $bosswin = newwin( $LINES, $COLS, 0, 0 );
    move( $bosswin, 0, 0 );
    addstring( $bosswin, <<'EOS');
    they not speak?
    Will not the Mayor then and his brethren come?
  BUCKINGHAM. The Mayor is here at hand. Intend some fear;
    Be not you spoke with but by mighty suit;
    And look you get a prayer-book in your hand,
    And stand between two churchmen, good my lord;
    For on that ground I'll make a holy descant;
    And be not easily won to our requests.
    Play the maid's part: still answer nay, and take it.
  GLOUCESTER. I go; and if you plead as well for them
    As I can say nay to thee for myself,
    No doubt we bring it to a happy issue.
  BUCKINGHAM. Go, go, up to the leads; the Lord Mayor
    knocks.                                      Exit GLOUCESTER

           Enter the LORD MAYOR, ALDERMEN, and citizens

    Welcome, my lord. I dance attendance here;
    I think the Duke will not be spoke withal.

                         Enter CATESBY

    Now, Catesby, what says your lord to my request?
EOS
    addstring( $bosswin, ':' );

    return $self;
}

method input {
    my ( $ch, $key ) = getchar;
    if ( defined $key ) {
        return $key_inputs{$key} // INPUT_NOOP;
    } elsif ( defined $ch ) {
        return $ch_inputs{$ch} // INPUT_NOOP;
    }
    return INPUT_NOOP;
}

END { endwin }
method quit { endwin }

# I recall that some Apple //e games had a boss screen that would bring
# up a spreadsheet or something so you could quickly look like you were
# actually working at work. This method is perhaps less effective given
# the creepy corporate tracking tools that are available these days.
method boss {
    curs_set(1);
    nodelay(0);
    refresh($bosswin);
    getchar;
    curs_set(0);
    nodelay(1);
    touchwin($map);
    touchwin;
    noutrefresh($map);
    noutrefresh;
    doupdate;
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
    getchar;
    erase;
    nodelay(1);
    return $self;
}

method update($game) {
    my $level_map = $game->level_map;
    for my $row ( 0 .. WORLD_ROWS - 1 ) {
        for my $col ( 0 .. WORLD_COLS - 1 ) {
            my $obj = $level_map->[$row][$col];
            addch( $map, $row, $col, $obj2ch{$obj} // 'Q' );
        }
    }
    refresh($map);
    return $self;
}

########################################################################
#
# SUBROUTINES

sub emit_center ( $text, $row = int( $LINES / 2 ) ) {
    my $length = length($text) / 2;
    addstring( $row, int( $COLS / 2 - $length ), $text );
}

# we're defining our own primary colors because who knows what the
# terminal has the COLOR_* set to
sub setup_curses_colors {
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

1;
__END__
=head1 NAME

Game::SuperSokohire3::Interface::Curses - terminal interface

=head1 DESCRIPTION

This module provides an interface for L<Game::SuperSokohire3> to run
under a terminal.

=cut
