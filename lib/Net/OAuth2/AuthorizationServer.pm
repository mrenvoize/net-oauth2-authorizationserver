package Net::OAuth2::AuthorizationServer;

=head1 NAME

Net::OAuth2::AuthorizationServer - Easier implementation of an OAuth2
Authorization Server

=for html
<a href='https://travis-ci.org/G3S/net-oauth2-authorizationserver?branch=master'><img src='https://travis-ci.org/G3S/net-oauth2-authorizationserver.svg?branch=master' alt='Build Status' /></a>
<a href='https://coveralls.io/r/G3S/net-oauth2-authorizationserver?branch=master'><img src='https://coveralls.io/repos/G3S/net-oauth2-authorizationserver/badge.png?branch=master' alt='Coverage Status' /></a>

=head1 VERSION

0.02

=head1 SYNOPSIS

    my $Server = Net::OAuth2::AuthorizationServer->new;

    my $Grant  = $Server->auth_code_grant(
        ...
    );

=head1 DESCRIPTION

This module is the gateway to the various OAuth2 grant flows, as documented
at L<https://tools.ietf.org/html/rfc6749>. You should see the various modules
within this distribution for the implementation and usage details on various
types of grant flows.

=cut

use strict;
use warnings;

use Moo;
use Types::Standard qw/ :all /;

use Net::OAuth2::AuthorizationServer::AuthorizationCodeGrant;

our $VERSION = '0.02';

=head2 auth_code_grant

OAuth Authorisation Code Grant as document at L<http://tools.ietf.org/html/rfc6749#section-4.1>.

See L<Net::OAuth2::AuthorizationServer::AuthorizationCodeGrant>.

=cut

sub auth_code_grant {
    my ( $self, @args ) = @_;
    return Net::OAuth2::AuthorizationServer::AuthorizationCodeGrant->new( @args, );
}

=head2 implicit_grant

=head2 resource_owner_password_grant

=head2 client_grant

=head2 extension_grant

Not yet implemented.

=cut

=head1 EXAMPLES

There are examples included with this distribution in the examples/ dir.
See examples/README for more information about these examples.

=head1 REFERENCES

=over 4

=item * L<http://oauth.net/documentation/>

=item * L<http://tools.ietf.org/html/rfc6749>

=back

=head1 SEE ALSO

L<Mojolicious::Plugin::OAuth2::Server> - A Mojolicious plugin using this module

=head1 AUTHOR

Lee Johnson - C<leejo@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. If you would like to contribute documentation
or file a bug report then please raise an issue / pull request:

    https://github.com/G3S/net-oauth2-authorizationserver

=cut

__PACKAGE__->meta->make_immutable;
