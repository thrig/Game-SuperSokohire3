# -*- Perl -*-
#
# $Id: Random.pm,v 1.3 2022/06/03 13:15:34 jmates Exp $

package Game::SuperSokohire3::Random 0.02;
use parent qw(Exporter);

require XSLoader;
XSLoader::load;

my @elist = qw( coinflip init_jsf irand onein pick rnd_point roll );
our @EXPORT_TAGS = ( ':all' => \@elist );
our @EXPORT_OK   = @elist;

1;
__END__
=head1 NAME

Game::SuperSokohire3:Random - RNG and related utility functions

=head1 DESCRIPTION

Wrapper module with utility functions around a 32-bit Jenkins Small
Fast PRNG. Something must call C<init_jsf> before any of the other
routines are used.

=cut
