# -*- Perl -*-
#
# $Id: Corridors.pm,v 1.6 2022/06/04 20:05:23 jmates Exp $
#
# twisty passage maker

package Game::SuperSokohire3::Corridors 0.02;
use Object::Pad 0.52;

class Game::SuperSokohire3::Corridors :strict(params);
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random qw(coinflip onein random_point random_turn);

# agents only move forward in some direction, with various
# randomizations to make things a bit more interesting
use constant {
    AGENT_MOVES   => 0,    # used something like a time-to-live
    AGENT_HEADING => 1,    # index into HEADINGS
    AGENT_Y       => 2,    # position
    AGENT_X       => 3,
};

# hjkl only, tsplit and random_turn abuse the 0b11 nature of 0..3
our @HEADINGS = ( [ 1, 0 ], [ 0, -1 ], [ -1, 0 ], [ 0, 1 ] );

# NOTE the agents can go beyond max_moves as that's only checked every
# so often; max_moves should not be larger than maybe 50% of the map.
has @agents;
# points modified, for use by subsequent code
has $carved :mutator;
# 2D grid of integers, only points OBJ_UNSEEN will be modified
has $map       :param;
has $max_moves :param;
# where to start from, as the calling code probably knows where the
# stairs or vault entrances are (otherwise, random starting point(s))
has $start :param;
has $total_moves = 0;
has $ymax;
has $xmax;

ADJUST {
    $ymax = $map->@*;
    $xmax = $map->[0]->@*;    # assumes map is a rectangle
    for my $point (@$start) {
        $self->new_agents_at( $point, 100 );
    }
    while ( $total_moves < $max_moves ) {
        $self->add_random_agent unless @agents;
        $self->iterate;
    }
}

# NOTE this will softlock if there is not enough free space to spawn
# agents into. there are more efficient ways to generate mostly open
# levels or to pathfind between vaults that occupy large portions of
# a level map
method add_random_agent {
    while (1) {
        my @point = random_point( $ymax, $xmax );
        if ( $map->[ $point[YY] ][ $point[XX] ] == OBJ_UNSEEN ) {
            $self->new_agents_at( \@point, 10 );
            return;
        }
    }
}

# TODO the onein() may need tuning as corridors.pl is aimed at a
# slightly larger level map than the 64x16 in use here
method iterate {
    my @entnew;
  AGENT: for my $ent (@agents) {
        my @newpos = ( $ent->[AGENT_Y], $ent->[AGENT_X] );
        my $hyx    = $HEADINGS[ $ent->[AGENT_HEADING] ];
        for my $i ( YY, XX ) { $newpos[$i] += $hyx->[$i] }

        if (   $newpos[YY] < 0
            or $newpos[YY] >= $ymax
            or $newpos[XX] < 0
            or $newpos[XX] >= $xmax ) {
            # it fell off the edge of the world
            undef $ent;
            next AGENT;
        }
        if ( $map->[ $newpos[YY] ][ $newpos[XX] ] != OBJ_UNSEEN ) {
            # this can create open areas if it happens a lot
            push @entnew, $self->tsplit($ent) if onein(8);
            undef $ent;
            next AGENT;
        }

        $map->[ $newpos[YY] ][ $newpos[XX] ] = OBJ_EMPTY;
        push @$carved, \@newpos;

        # spice things up with random turns, spawns, etc
        my $moves = $ent->[AGENT_MOVES];
        if ( $moves > 2 ) {
            if ( onein(10) ) {
                $ent->@[ AGENT_MOVES, AGENT_HEADING ] =
                  ( 0, random_turn( $ent->[AGENT_HEADING] ) );
                next AGENT;
            } else {
                if ( onein(6) ) {
                    push @entnew, $self->tsplit($ent);
                    if ( $moves > 6 and onein(10) ) {
                        undef $ent;
                        next AGENT;
                    }
                }
            }
            if ( onein(3) ) {
                my @nudge = @newpos;
                my $hyx   = $HEADINGS[ random_turn( $ent->[AGENT_HEADING] ) ];
                for my $i ( YY, XX ) { $nudge[$i] += $hyx->[$i] }

                if (    $nudge[YY] >= 0
                    and $nudge[YY] < $ymax
                    and $nudge[XX] >= 0
                    and $nudge[XX] < $xmax
                    and $map->[ $nudge[YY] ][ $nudge[XX] ] == OBJ_UNSEEN ) {
                    $map->[ $nudge[YY] ][ $nudge[XX] ] = OBJ_EMPTY;
                    push @$carved, \@nudge;
                    @newpos = @nudge;
                    $ent->[AGENT_MOVES] = 0;
                }
            }
        }

        $ent->[AGENT_MOVES]++;
        $ent->@[ AGENT_Y, AGENT_X ] = @newpos;
        $total_moves++;
    }
    @agents = ( @entnew, grep defined, @agents );
}

# usually up to four agents heading away from each other
method new_agents_at( $point, $odds = undef ) {
    # ensure starting point has been seen and is walkable
    $map->[ $point->[YY] ][ $point->[XX] ] = OBJ_EMPTY
      if $map->[ $point->[YY] ][ $point->[XX] ] == OBJ_UNSEEN;
    for my $h ( 0 .. $#HEADINGS ) {
        if ( defined $odds and onein($odds) ) {
            $odds *= 4;
            next;
        }
        my $ent;
        $ent->@[ AGENT_MOVES, AGENT_HEADING, AGENT_Y, AGENT_X ] =
          ( 0, $h, $point->@[ YY, XX ] );
        push @agents, $ent;
    }
}

# make an orthogonal "T" split from the given agent, usually due to said
# agent having run into some obstacle, such as a minority that retards
# forward progress
method tsplit($ent) {
    my @ents;
    for my $nah ( $ent->[AGENT_HEADING] & 1 ? ( 0, 2 ) : ( 1, 3 ) ) {
        my $new;
        $new->@[ AGENT_MOVES, AGENT_HEADING, AGENT_Y, AGENT_X ] =
          ( 0, $nah, $ent->@[ AGENT_Y, AGENT_X ] );
        push @ents, $new;
    }
    # sometimes less than a full "T"
    splice @ents, coinflip, 1 if onein(4);
    return @ents;
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::Corridors - twisty passage maker thing

=head1 DESCRIPTION

Makes twisty passages by way of corridors.pl by way of corridors.lisp in
the ministry-of-silly-vaults repository.

=cut
