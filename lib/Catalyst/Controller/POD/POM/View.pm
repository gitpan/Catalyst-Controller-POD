package Catalyst::Controller::POD::POM::View;

use base "Pod::POM::View::HTML";

    sub _root {
        my $self = shift;
        if(@_) {
            $self->{_root} = $_[0];
        }
        return $self->{_root};
    }


    sub _module {
        my $self = shift;
        if(@_) {
            $self->{_module} = $_[0];
        }
        return $self->{_module};
    }


sub view_pod {
    my ($self, $pod) = @_;
    return qq~
<html>
<head>
<link rel="stylesheet" href="http://search.cpan.org/s/style.css" type="text/css">
</head>
<body bgcolor=\"#ffffff\"><div class="pod">
~
 	. $pod->content->present($self)
        . "</div></body></html>\n";
}

sub view_verbatim {
    my ($self, $text) = @_;
    
    for ($text) {
	s/&/&amp;/g;
	s/</&lt;/g;
	s/>/&gt;/g;
    }
    foreach my $i (1..10) {
    	my $t;
    	my $last = 0;
    	for(split(/\n/, $text)) {
    		$_ =~ s/^(.)//;
    		if($1 ne " ") {
    			$last = 1;
    			last;
    		}
    		$t .= $_.$/;
    	}
    	$text = $t unless($last);
    	last if($last);
    }
    
    return "<pre>$text</pre>\n\n";
}

sub view_seq_link_transform_path {
	my($self,$page) = @_;
	return $self->_root."/module/$page";	
}

sub Pod::POM::View::HTML::make_href  {
    my($url, $title) = @_;
	if (!defined $url) {
        $url = "$title";
    }

    $title = $url unless defined $title;
    return qq{<a href="$url" onclick="return POD.proxyLink(this)">$title</a>};
}

sub view_head1 {
    my ($self, $head1) = @_;
    my $title = $head1->title->present($self);
    my $id = "section-".$self->_module."-".$title;
    return "<h1 id='$id'>$title</h1>\n\n"
	. $head1->content->present($self);
}


sub view_head2 {
    my ($self, $head2) = @_;
    my $title = $head2->title->present($self);
    my $id = "section-".$self->_module."-".$title;
    return "<h2 id='$id'>$title</h2>\n\n"
	. $head2->content->present($self);
}


sub view_head3 {
    my ($self, $head3) = @_;
    my $title = $head3->title->present($self);
    my $id = "section-".$self->_module."-".$title;
    return "<h3 id='$id'>$title</h3>\n\n"
	. $head3->content->present($self);
}


sub view_head4 {
    my ($self, $head4) = @_;
    my $title = $head4->title->present($self);
    my $id = "section-".$self->_module."-".$title;
    return "<h4 id='$id'>$title</h4>\n\n"
	. $head4->content->present($self);
}



1;