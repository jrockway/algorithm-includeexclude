package Algorithm::IncludeExclude;

use warnings;
use strict;
use Carp;

=head1 NAME

Algorithm::IncludeExclude - build and evaluate include/exclude lists

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

   my $ie = Algorithm::IncludeExclude->new;
   
   # setup rules
   $ie->include();                      # default to include
   $ie->exclude('foo');
   $ie->exclude('bar');
   $ie->include('foo','baz');

   # evaluate candidates
   $ie->evaluate(qw/foo bar/);          # exclude
   $ie->evaluate(qw/quux foo bar/);     # include
   $ie->evaluate(qw/foo baz quux/);     # include
   $ie->evaluate(qw/bar baz/);          # exclude

=head1 Methods

=head2 new

=cut

# self is a tree, that looks like:
# {path1 => [ value1, {path2 => [ value2, ... ]}]}
# path1 has value value1
# path1->path2 has value value2
# path3 is undefined
# etc

sub new {
    my $class = shift;
    my $args = shift || {};
    $args->{join} ||= ''; # avoid warnings
    $args->{regexes} = {};
    my $self = [undef, {}, $args];
    return bless $self => $class;
}

# walks down the tree and sets the value of path to value
sub _set {
    my $tree  = shift;
    my $path  = shift;
    my $value = shift;
    
    my $regexes = $tree->[2]->{regexes};

    my $ref = 0;
    foreach my $head (@$path){
	# ignore everything after a qr// rule
	croak "Ignoring values after a qr// rule" if $ref;
	if(ref $head){
	    $ref = 1;
	    $regexes->{"X$head"} = $head;
	    $head = "X$head";
	}
	else {
	    $head = "0$head";
	}
	my $node = $tree->[1]->{$head};
	$node = $tree->[1]->{$head} = [undef, {}]
	  if('ARRAY' ne ref $node);
	
	$tree = $node;
    }
    $tree->[0] = $value;
}

=head2 include

=cut

sub include {
    my $self = shift;
    my @path = @_;
    $self->_set(\@path, 1);
}

=head2 exclude

=cut

sub exclude {
    my $self = shift;
    my @path = @_;
    $self->_set(\@path, 0);
}

=head2 evaluate

=cut

sub evaluate {
    my $self = shift;
    my @path = @_;
    my $value = $self->[0];
    my $tree  = [@{$self}]; # unbless

    # "constants" (in here anyway)
    my %REGEXES = %{$self->[2]->{regexes}};
    my $JOIN = $self->[2]->{join};
    
    while(my $head = shift @path){
	# get regexes at this level;
	my @regexes = 
	  grep { defined }
	    map { $REGEXES{$_} } 
	      grep { /^X/ }
		keys %{$tree->[1]};
	
	if(@regexes){
	    my $matches = 0;
	    my $rest = join $JOIN, ($head,@path);
	    foreach my $regex (@regexes){
		if($rest =~ /$regex/){
		    $value = $tree->[1]->{"X$regex"}->[0];
		    $matches++;
		}
	    }
	    return undef if($matches > 1);
	    return $value if $matches == 1;
	}

	$tree = $tree->[1]->{"0$head"};
	last unless ref $tree;
	$value = $tree->[0];
    }

    return $value;
}

=head1 AUTHOR

Jonathan Rockway, C<< <jrockway at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-algorithm-includeexclude at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Algorithm-IncludeExclude>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::IncludeExclude

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-IncludeExclude>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-IncludeExclude>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-IncludeExclude>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-IncludeExclude>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jonathan Rockway, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Algorithm::IncludeExclude
