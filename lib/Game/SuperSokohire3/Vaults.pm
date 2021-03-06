# -*- Perl -*-
#
# $Id: Vaults.pm,v 1.5 2022/06/14 21:21:00 jmates Exp $
#
# pre-made vaults and related code for map generation

package Game::SuperSokohire3::Vaults 0.02;
use Game::SuperSokohire3::Common;
use Game::SuperSokohire3::Random 'irand';

use parent qw(Exporter);
our @EXPORT;
BEGIN { @EXPORT = qw(make_vault) }

# NOTE the open end of a vault or what the player will interact with, if
# any, should point East, to the right, direction 0. this allows a 180
# degree rotated vault to be placed on the Eastern edge of the map,
# because the "business end" is known to point West
our %vaults = (
    exit => {
        grid => [
            [ 3, 5,  3, ],    # these doors really need locks
            [ 5, 7, 5, ],
            [ 3, 5,  3, ],
        ],
        norotate => 1,
        template => 1,
        walkable => 1,
    },
    stairdoor => {
        grid => [
            [ 3, 3,  3, ],    # door will need locking code, maybe
            [ 3, -2, 5, ],
            [ 3, 3,  3, ],
        ],
        template => 1,
        walkable => 1,
    },
    stairbrogue => {
        grid => [
            [ 3, 3,  -1 ],    # Brogue-style semi-enclosed stair
            [ 3, -2, 0, ],    # 3x3 so it lines up with threethree
            [ 3, 3,  -1, ],
        ],
        template => 1,
        walkable => 1,
    },
    threethree => {
        grid => [
            [ 3, 3, 3, ],     # to block out a multi-level stair
            [ 3, 3, 3, ],
            [ 3, 3, 3, ],
        ],
        norotate => 1,
    },
);

# these assume a unit circle and line up with East, North, West, South.
# all perform a copy of the presumably original vault
our @transform = ( \&rot0, \&rot90, \&rot180, \&rot270 );

# potentially walkable, anyways
our %walkable;
@walkable{ OBJ_EMPTY, OBJ_DOOR, OBJ_STAIRUP, OBJ_STAIRDOWN, } = ();

########################################################################
#
# SUBROUTINES

# get a vault by name, rotate a copy of it randomly, return that result
# and a bunch of metadata to the caller
sub make_vault ($name) {
    die "no such vault '$name'\n" unless exists $vaults{$name};    # DBG

    my $vault = $vaults{$name};
    my $rot   = $vault->{norotate} ? 0 : irand(4);
    my $grid  = $transform[$rot]->( $vault->{grid} );
    # non-symmetric might get a suitable flip_* here

    my ( $rows, $cols ) = ( $grid->$#*, $grid->[0]->$#* );

    my @walk;
    if ( $vault->{walkable} ) {
        for my $y ( 0 .. $rows ) {
            push @walk, [ $y, 0 ]     if exists $walkable{ $grid->[$y][0] };
            push @walk, [ $y, $cols ] if exists $walkable{ $grid->[$y][-1] };
        }
        if ( $cols > 1 ) {
            for my $x ( 1 .. $cols - 1 ) {
                push @walk, [ 0, $x ] if exists $walkable{ $grid->[0][$x] };
                push @walk, [ $rows, $x ] if exists $walkable{ $grid->[-1][$x] };
            }
        }
    }

    return $grid, $rows, $cols, \@walk,
      { rot => $rot,
        exists $vault->{template} ? ( template => 1 ) : ()
      };
}

sub rot0 ($grid) {
    my @new;
    for my $row ( $grid->@* ) { push @new, [ $row->@* ] }
    return \@new;
}

sub rot90 ($grid) {
    my @new;
    my ( $rows, $cols ) = ( $grid->$#*, $grid->[0]->$#* );
    for my $i ( 0 .. $rows ) {
        for my $j ( 0 .. $cols ) {
            $new[ $cols - $j ][$i] = $grid->[$i][$j];
        }
    }
    return \@new;
}

sub rot180 ($grid) {
    my @new;
    for my $row ( $grid->@* ) { unshift @new, [ reverse $row->@* ]; }
    return \@new;
}

sub rot270 ($grid) {
    my @new;
    my ( $rows, $cols ) = ( $grid->$#*, $grid->[0]->$#* );
    for my $i ( 0 .. $rows ) {
        for my $j ( 0 .. $cols ) {
            $new[$j][ $rows - $i ] = $grid->[$i][$j];
        }
    }
    return \@new;
}

# non-symmetric vaults could be flipped about a suitable axis;
# flip_* operate in-place on the assumption that a rot* transform
# has made a copy
sub flip_horizontal ($grid) {
    @$grid = reverse @$grid;
    return;
}

sub flip_vertical ($grid) {
    for my $row ( $grid->@* ) {
        @$row = reverse $row->@*;
    }
    return;
}

1;
__END__
=head1 NAME

Game::SuperSokohire3::Vaults - pre-made map elements and related code

=cut
