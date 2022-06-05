#!perl
#
# $Id: 20-corridors.t,v 1.5 2022/06/04 20:05:23 jmates Exp $
#
# are the corridors at least not horribly buggy?

use 5.26.0;
use Test2::V0;

use Game::SuperSokohire3::Constants;
use Game::SuperSokohire3::Random 'init_jsf';
use Game::SuperSokohire3::Corridors;

init_jsf(0);

my $corr;

# too small and causes agents to fall off of the map: what is good for
# testing and code coverage may be bad for gameplay
my @map = ( [ OBJ_UNSEEN, OBJ_WALL, OBJ_UNSEEN ] );

my $okay = eval {
    local $SIG{ALRM} = sub { die "softlock\n" };
    alarm 1;
    $corr = Game::SuperSokohire3::Corridors->new(
        map       => \@map,
        max_moves => 999,
        start     => [],      # force new_agents_at
    );
    alarm 0;
    1;
};
isnt( $okay, 1 ) or bail_out("did not softlock??");
is( $@,    "softlock\n" );
is( \@map, [ [ OBJ_EMPTY, OBJ_WALL, OBJ_EMPTY ] ] );

########################################################################
#
# RANDOM MAP

my $seed = unpack L => pack L => time() ^ $$;
diag "# JSF seed $seed";
init_jsf($seed);

my ( $max_moves, $mapy, $mapx ) = ( 100, 16, 64 );

for my $row ( 0 .. $mapy ) {
    for my $col ( 0 .. $mapx ) {
        $map[$row][$col] = OBJ_UNSEEN;
    }
}

$corr = Game::SuperSokohire3::Corridors->new(
    map       => \@map,
    max_moves => $max_moves,
    start     => [ [ 5, 15 ] ]
);

# in the model of an ancient general, does it at least produce somewhat
# good-looking results?
my %obj2ch = ( OBJ_EMPTY, '.', OBJ_UNSEEN, '#', OBJ_WALL, '#', );
my $count  = 0;
my $mmm    = '';
my %unknown;
for my $row ( 0 .. $mapy ) {
    for my $col ( 0 .. $mapx ) {
        my $ch = $obj2ch{ $map[$row][$col] };
        if ( defined $ch ) {
            $mmm .= $ch;
            $count++;
        } else {
            $unknown{ $map[$row][$col] } = 1;
        }
    }
    $mmm .= "\n";
}
ok( $count > 0 );
diag "a random map:\n" . $mmm;

my $points = $corr->carved;
ok( scalar @$points > 10 );

is( scalar keys %unknown, 0 );
if ( keys %unknown ) {
    diag "warning: unknown map elements: " . join( ' ', sort keys %unknown );
}

done_testing;
