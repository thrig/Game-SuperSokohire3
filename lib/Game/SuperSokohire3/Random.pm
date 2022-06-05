# -*- Perl -*-
#
# $Id: Random.pm,v 1.8 2022/06/05 05:13:07 jmates Exp $

package Game::SuperSokohire3::Random;

our $VERSION = '0.02';

use parent qw(Exporter);
require XSLoader;
XSLoader::load( __PACKAGE__, $VERSION );

my @elist = qw( bypair
  coinflip extract init_jsf irand onein pick random_point random_turn roll );
our %EXPORT_TAGS = ( all => \@elist );
our @EXPORT_OK   = @elist;

1;
__END__
=head1 NAME

Game::SuperSokohire3:Random - RNG and related utility functions

=head1 DESCRIPTION

Wrapper module with utility functions around a 32-bit Jenkins Small Fast
PRNG. Something must call C<init_jsf> with a seed before any of the
other routines are used.

=cut
