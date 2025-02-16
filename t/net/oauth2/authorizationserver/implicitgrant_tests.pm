package implicitgrant_tests;

use strict;
use warnings;

use Test::Most;
use Test::Exception;

sub callbacks {
	my ( $Grant ) = @_;
	return (
		verify_client_cb => sub { return Net::OAuth2::AuthorizationServer::ImplicitGrant::_verify_client( $Grant,@_ ) },
		store_access_token_cb => sub { return Net::OAuth2::AuthorizationServer::ImplicitGrant::_store_access_token( $Grant,@_ ) },
		verify_access_token_cb => sub { return Net::OAuth2::AuthorizationServer::ImplicitGrant::_verify_access_token( $Grant,@_ ) },
	);
}

sub clients {

	return {
		test_client => {
			scopes => {
				eat   => 1,
				drink => 0,
				sleep => 1,
			},
		},
		test_client_with_redirect_uri => {
			redirect_uri => 'https://foo.bar.baz.com',
			scopes => {
				eat   => 1,
				drink => 0,
				sleep => 1,
			},
		},
		test_client_must_use_auth_code => {
			client_secret => 'weeee',
			scopes => {
				eat   => 1,
				drink => 0,
				sleep => 1,
			},
		},
	};
}

sub run_tests {
	my ( $Grant,$args ) = @_;

	$args //= {};

	can_ok(
		$Grant,
		qw/
			clients
		/
	);

	note( "verify_client" );

	my %invalid_client = (
		client_id => 'test_client_must_use_auth_code',
		scopes    => [ qw/ eat sleep / ],
	);

	my ( $res,$error ) = $Grant->verify_client( %invalid_client );

	ok( ! $res,'->verify_client, client cannot use implicit grant' );
	is( $error,'unauthorized_client','has error' );

	%invalid_client = (
		client_id => 'test_client_with_redirect_uri',
		scopes    => [ qw/ eat sleep / ],
	);

	( $res,$error ) = $Grant->verify_client( %invalid_client );

	ok( ! $res,'->verify_client, lacks redirect_uri' );
	is( $error,'invalid_request','has error' );

	$invalid_client{'redirect_uri'} = 'http://not.right.com';

	( $res,$error ) = $Grant->verify_client( %invalid_client );

	ok( ! $res,'->verify_client, incorrect redirect_uri' );
	is( $error,'invalid_request','has error' );

	$invalid_client{'redirect_uri'} = 'https://foo.bar.baz.com';

	( $res,$error ) = $Grant->verify_client( %invalid_client );

	ok( $res,'->verify_client, correct redirect_uri' );
	ok( ! $error,'has no error' );

	my %valid_client = (
		client_id => 'test_client',
		scopes    => [ qw/ eat sleep / ],
	);

	( $res,$error ) = $Grant->verify_client( %valid_client );

	ok( $res,'->verify_client, allowed scopes' );
	ok( ! $error,'has no error' );

	foreach my $t (
		[ { scopes => [ qw/ eat sleep drink / ] },'access_denied','disallowed scopes' ],
		[ { scopes => [ qw/ eat sleep yawn / ] },'invalid_scope','invalid scopes' ],
		[ { client_id => 'another_client' },'unauthorized_client','invalid client' ],
	) {
		( $res,$error ) = $Grant->verify_client( %valid_client,%{ $t->[0] } );

		ok( ! $res,'->verify_client, ' . $t->[2] );
		is( $error,$t->[1],'has error' );
	}

	note( "store_access_token" );

	ok( my $access_token = $Grant->token(
		client_id    => 'test_client',
		scopes       => [ qw/ eat sleep / ],
		type         => 'access',
		user_id      => 1,
	),'->token (access token)' );

	$args->{token_format_tests}->( $access_token,'access' )
		if $args->{token_format_tests};

	ok( $Grant->store_access_token(
		client_id     => 'test_client',
		access_token  => $access_token,
		scopes       => [ qw/ eat sleep / ],
	),'->store_access_token' );

	note( "verify_access_token" );

	( $res,$error ) = $Grant->verify_access_token(
		access_token     => $access_token,
		scopes           => [ qw/ eat sleep / ],
	);

	ok( $res,'->verify_access_token, valid access token' );
	ok( ! $error,'has no error' );

	( $res,$error ) = $Grant->verify_access_token(
		access_token     => $access_token,
		scopes           => [ qw/ drink / ],
	);

	ok( ! $res,'->verify_access_token, invalid scope' );
	is( $error,'invalid_grant','has error' );

	( $res,$error ) = $Grant->verify_token_and_scope(
		auth_header      => "Bearer $access_token",
		scopes           => [ qw/ eat sleep / ],
	);

	ok( $res,'->verify_token_and_scope, valid access token' );
	ok( ! $error,'has no error' );

	my $og_access_token = $access_token;
	chop( $access_token );

	( $res,$error ) = $Grant->verify_access_token(
		access_token     => $access_token,
		scopes           => [ qw/ eat sleep / ],
	);

	ok( ! $res,'->verify_access_token, token fiddled with' );
	is( $error,'invalid_grant','has error' );

	unless ( $args->{cannot_revoke} ) {

		( $res,$error ) = $Grant->verify_access_token(
			access_token     => $access_token,
			scopes           => [ qw/ eat sleep / ],
		);

		ok( ! $res,'->verify_access_token, access token revoked' );
		is( $error,'invalid_grant','has error' );
	}

	return $og_access_token;
}

1;
