#!/usr/bin/perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Controller::POD' );
}

diag( "Testing Memoria::PDF $Memoria::PDF::VERSION, Perl $], $^X" );
