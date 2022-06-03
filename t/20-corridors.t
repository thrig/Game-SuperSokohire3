#!perl
#
# $Id: 20-corridors.t,v 1.1 2022/06/03 13:01:46 jmates Exp $
#
# are the corridors at least not horribly buggy?

use 5.26.0;
use Test2::V0;

use Data::Dumper::Concise::Aligned;    # DBG
use Game::SuperSokohire3::Constants;
use Game::SuperSokohire3::Random 'init_jsf';
use Game::SuperSokohire3::Corridors;

init_jsf(0);

my @map;
for my $row ( 0 .. 10 ) {
    for my $col ( 0 .. 20 ) {
        $map[$row][$col] = OBJ_UNSEEN;
    }
}

my $corr = Game::SuperSokohire3::Corridors->new(
    map       => \@map,
    max_moves => 10,
    start     => [ [ 5, 15 ] ]
);

my %obj2ch = ( OBJ_EMPTY, '.', OBJ_UNSEEN, '?', OBJ_WALL, '#', );
my $count  = 0;
my $s      = '';
my %unknown;
for my $row ( 0 .. 10 ) {
    for my $col ( 0 .. 20 ) {
        my $ch = $obj2ch{ $map[$row][$col] };
        if ( defined $ch ) {
            $s .= $ch;
            $count++;
        } else {
            $unknown{ $map[$row][$col] } = 1;
        }
    }
    $s .= "\n";
}
ok( $count > 0 );
diag "a map:\n" . $s;

if ( keys %unknown ) {
    diag "warning: unknown map elements: " . join( ' ', sort keys %unknown );
}

my $points = $corr->carved;
ok( scalar @$points > 0 );
diag DumperA P => $points;

done_testing;
