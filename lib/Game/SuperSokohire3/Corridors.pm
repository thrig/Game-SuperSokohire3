# -*- Perl -*-
#
# $Id: Corridors.pm,v 1.3 2022/06/03 13:15:34 jmates Exp $
#
# twisty passage generator mark I super beta

package Game::SuperSokohire3::Corridors 0.02;
use Object::Pad 0.52;

class Game::SuperSokohire3::Corridors :strict(params);
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random qw(coinflip onein rnd_point);

use constant {
    AGENT_HEADING => 0,    # index into HEADINGS
    AGENT_Y       => 1,    # position
    AGENT_X       => 2,
    AGENT_MOVES   => 3,    # something like a TTL
};

our @HEADINGS = ( [ 1, 0 ], [ 0, -1 ], [ -1, 0 ], [ 0, 1 ] );

# NOTE the agents can go beyond max_moves as that's only checked every
# so often. for certain map dimensions a percent of that in moves, minus
# a little, should work
has @agents;
has $carved    :reader;
has $map       :param;
has $max_moves :param;
has $start     :param;
has $total_moves = 0;
has $ymax;
has $xmax;

ADJUST {
    $ymax = $map->@*;
    $xmax = $map->[0]->@*;
    for my $point (@$start) {
        # TODO I feel like the caller should have already marked the
        # point but that code isn't written yet, so for now...
        $map->[ $point->[0] ][ $point->[1] ] = OBJ_EMPTY
          if $map->[ $point->[0] ][ $point->[1] ] == OBJ_UNSEEN;
        # TODO don't always make a 4-way from every start point, but
        # then if agent dies may need to retry with an unused heading?
        # or some means of better connecting things up...
        $self->new_agents_at($point);
    }
    while ( $total_moves < $max_moves ) {
        $self->add_random_agent unless @agents;
        $self->iterate;
    }
}

method add_random_agent {
    # avoid "not enough moves, nowhere to put a new agent" deadlock
    state $tries = 0;
    while (1) {
        if ( $tries++ > 10 ) { $total_moves = $max_moves; return }
        my @point = rnd_point( $ymax, $xmax );
        if ( $map->[ $point[0] ][ $point[1] ] == OBJ_UNSEEN ) {
            $self->new_agents_at( \@point );
            return;
        }
    }
}

method iterate {
    my @new;
    for my $ent (@agents) {
        my @newpos = ( $ent->[AGENT_Y], $ent->[AGENT_X] );
        my $hyx    = $HEADINGS[ $ent->[AGENT_HEADING] ];
        for my $j ( 0 .. 1 ) { $newpos[$j] += $hyx->[$j] }

        if (   $newpos[0] < 0
            or $newpos[0] >= $ymax
            or $newpos[1] < 0
            or $newpos[1] >= $xmax ) {
            undef $ent;
            # TODO fork2 (prong?) it
            next;
        }
        if ( $map->[ $newpos[0] ][ $newpos[1] ] != OBJ_UNSEEN ) {
            # TODO maybe prong (creates open areas...)
            undef $ent;
            next;
        }

        $map->[ $newpos[0] ][ $newpos[1] ] = OBJ_EMPTY;
        # TODO or only sample these to get a few selected points to mess
        # with (and lower memory usage?) but will need to know where new
        # stairs can be dropped at... or possibly graph gen can use this
        # to build a map of the dungeon
        push @$carved, \@newpos;

        # spice things up with random turns, spawns, etc
        my $moves = $ent->[AGENT_MOVES];
        if ( $moves > 3 ) {
            if ( onein(10) ) {
                my $direction = coinflip ? 1 : -1;
                $ent->[AGENT_HEADING] = ( $ent->[AGENT_HEADING] + $direction ) % @HEADINGS;
                $ent->[AGENT_MOVES]   = 0;
                next;
            } else {
                if ( onein(6) ) {
                    # TODO maybe prong
                    # TODO maybe kill agent
                }
                if ( onein(3) ) {
                    # TODO maybe nudge agent
                }
            }
        }

        $ent->[AGENT_MOVES]++;
        $ent->@[ AGENT_Y, AGENT_X ] = @newpos;
        $total_moves++;
    }
    @agents = ( @new, grep defined, @agents );
}

method new_agents_at($point) {
    push @agents, map {
        my $ent = [];
        $ent->@[ AGENT_HEADING, AGENT_Y, AGENT_X, AGENT_MOVES ] = ( $_, $point->@*, 0 );
        $ent;
    } 0 .. $#HEADINGS;
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::Corridors - twisty passage maker

=head1 DESCRIPTION

Makes twisty passages by way of corridors.pl by way of corridors.lisp in
the ministry-of-silly-vaults repository.

=cut
