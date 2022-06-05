# -*- Perl -*-
#
# $Id: TestTest123.pm,v 1.1 2022/06/05 01:07:20 jmates Exp $
#
# while not a real interface it does increase code coverage and provides
# some other benefits

package Game::SuperSokohire3::Interface::TestTest123 0.02;
use Object::Pad 0.52;

class Game::SuperSokohire3::Interface::TestTest123 :strict(params);

has $ifn :param;

our %events;

method boss {
    $events{boss}++;
    return $self;
}

method update($game) {
    $events{update}++;
    return $self;
}

method init {
    $events{init}++;
    return $self;
}

method input {
    $events{input}++;
    return $ifn->();
}

method quit {
    $events{quit}++;
    die "gameover\n";    # KLUGE avoid subsequent exit 1 in caller
}

method title_screen {
    $events{title}++;
    return $self;
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::Interface::TestTest123 - test interface

=cut
