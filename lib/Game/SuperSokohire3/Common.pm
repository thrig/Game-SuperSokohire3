# -*- Perl -*-
#
# $Id: Common.pm,v 1.6 2022/06/02 22:08:58 jmates Exp $
#
# commonly used modules, features, and pull in important Constants

package Game::SuperSokohire3::Common 0.02;

use parent qw(Import::Base);

our @IMPORT_MODULES = (
    'strict',
    'warnings',
    feature      => [qw(say signatures state)],
    { 'Syntax::Keyword::Match' => 0.08 } => [qw{match :experimental(dispatch)}],
    'Game::SuperSokohire3::Constants',
    '>-warnings' => [qw(experimental::signatures)],
);

1;
__END__
=head1 NAME

Game::SuperSokohire3::Common - constants, module imports, etc

=head1 DESCRIPTION

This module causes various constants, features, and modules to turn up
in differnt modules under L<Game::SuperSokohire3>, if all goes well.

=cut
