#!perl
#
# $Id: 20-scrolls.t,v 1.3 2022/06/04 22:58:45 jmates Exp $

use 5.26.0;
use Test2::V0;

use Game::SuperSokohire3::Random 'init_jsf';
use Game::SuperSokohire3::Scrolls;

init_jsf(0);

my $enc = Game::SuperSokohire3::Scrolls::encrypt('foo');
is( Game::SuperSokohire3::Scrolls::decrypt($enc), 'foo' );

my $scroll_count = @Game::SuperSokohire3::Scrolls::scrolls;

my $snippet = Game::SuperSokohire3::Scrolls::text;
like( $snippet, qr/(?i)[aeiou]/ );

# are scrolls consumed on use? (text() returns undef when the
# scrolls run out)
is( scalar @Game::SuperSokohire3::Scrolls::scrolls, $scroll_count - 1 );

done_testing;
