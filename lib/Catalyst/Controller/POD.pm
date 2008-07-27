package Catalyst::Controller::POD;
use warnings;
use strict;
use File::Find qw( find );
use File::ShareDir qw( dist_file );
use File::Spec;
use File::Slurp;
use Pod::Simple::Search;
use JSON::XS;
use Pod::POM;
use LWP::Simple;
use List::MoreUtils qw(uniq);
use base "Catalyst::Controller";
use base "Class::Accessor::Fast";

use lib(qw(/Users/mo/Documents/workspace/Catalyst-Controller-POD/lib));

use Catalyst::Controller::POD::Template;
__PACKAGE__->mk_accessors(qw(_dist_dir));

=head1 NAME

Catalyst::Controller::POD - The great new Catalyst::Controller::POD!

=head1 VERSION

Version 0.01

=cut
our $VERSION = '0.01_02';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Catalyst::Controller::POD;

    my $foo = Catalyst::Controller::POD->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut

sub module : Local {
	my ( $self, $c, $module ) = @_;
	my $name2path =
	  Pod::Simple::Search->new($module)->inc(0)
	  ->survey( $c->path_to('lib')->stringify );

		my $view = "Catalyst::Controller::POD::POM::View";
		Pod::POM->default_view($view)
		  || die "$Pod::POM::ERROR\n";
		
		my $parser = Pod::POM->new( warn => 0 )
		  || die "$Pod::POM::ERROR\n";
		  $view->_root($self->_root);
		  $view->_module($module);
		
	my $pom;
	if ( $name2path->{$module} ) {

		$pom = $parser->parse_file( $name2path->{$module} )
		  || die $parser->error(), "\n";
	} else {
		my $html = get( "http://search.cpan.org/perldoc?" . $module );
		$html =~ s/.*<a href="(.*?)">Source<\/a>.*/$1/s;
		my $source = get("http://search.cpan.org". $html);
		$pom = $parser->parse_text( $source )
		  || die $parser->error(), "\n";
		
	}
	$c->res->body( $view->print($pom) );
}

sub modules : Local {
	my ( $self, $c ) = @_;
	my $name2path =
	  Pod::Simple::Search->new('Memoria::*')->inc(0)
	  ->survey( $c->path_to('lib')->stringify );
	my @modules;
	while ( my ( $k, $v ) = each %$name2path ) {
		push( @modules, $k );
	}
	@modules = sort @modules;
	my $json = _build_module_tree( [], "", @modules );
	$c->res->body( encode_json($json) );
}

sub _build_module_tree : Private {
	my $tree    = shift;
	my $stack   = shift;
	my @modules = @_;
	my @uniq    = uniq( map { ( split(/::/) )[0] } @modules );
	foreach my $root (@uniq) {
		my $name = $stack ? $stack . "::" . $root : $root;
		push( @{$tree}, { text => $root, name => $name } );
		my @children;
		for (@modules) {
			if ( $_ =~ /^$root\:\:(.*)$/ ) {
				push( @children, $1 );
			}
		}
		unless (@children) {
			$tree->[-1]->{leaf} = \1;
			next;
		}
		$tree->[-1]->{children} = [];
		$tree->[-1]->{children} =
		  _build_module_tree( $tree->[-1]->{children}, $name, @children );
	}
	return $tree;
}

sub _root {
	my ($self, $c) = @_;
	#my $root = $c->uri_for( $self->action_for(" static ") . "/.." );
	return "http://localhost:3000/docs";
				
}

sub new {
	my $self = shift;
	my $new  = $self->NEXT::new(@_);
	my $path;
	eval { $path = dist_file( 'Catalyst-Controller-POD', 'docs.js' ); };
	if ($@) {
		$path = "/Users/mo/Documents/workspace/Catalyst-Controller-POD/share";
	} else {
		my ( $volume, $dirs, $file ) = File::Spec->splitpath($path);
		$path = File::Spec->catfile( $volume, $dirs );
	}
	$new->_dist_dir($path);
	
	
	return $new;
}

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;
	
		$c->res->content_type('text/html; charset=utf-8');
	$c->response->body(
		Catalyst::Controller::POD::Template->get(
			$c->uri_for( $self->action_for("static") )
		)
	);
}

sub static : Path("static") {
	my ( $self, $c, @file ) = @_;
	my $file = File::Spec->catfile(@file);
	my $data;
	eval { $data = read_file( $self->_dist_dir . "/" . $file ) };
	if ($@) {
		$c->res->status(404);
		$c->res->content_type('text/html; charset=utf-8');
	} else {
		if ( $file eq "docs.js" ) {
			my $root = $self->_root;
			$data =~ s/\[% root %\]/$root/g;
		}
		$c->response->body($data);
	}
}

=head1 AUTHOR

Moritz Onken, C<< <onken at houseofdesign.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-controller-pod at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-Controller-POD>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catalyst::Controller::POD


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Catalyst-Controller-POD>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Catalyst-Controller-POD>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Catalyst-Controller-POD>

=item * Search CPAN

L<http://search.cpan.org/dist/Catalyst-Controller-POD>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of Catalyst::Controller::POD
