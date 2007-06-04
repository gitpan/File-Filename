package File::Filename;
use strict;
require Exporter;
use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = (qw(get_filename_segments));
our $VERSION = sprintf "%d.%02d", q$Revision: 1.1 $ =~ /(\d+)/g;

sub get_filename_segments {
	my $filename = shift;
	$filename or warn('get_fields_arrayref() no arg.') and return;	
	my $separators = shift;	
	$separators ||= 	qr/[^a-zA-Z0-9 ]+/;

	$filename=~s/^.+\/+//;
	
	my @fields = map { $_=~s/^\s+|\s+$//g; $_ } grep { /./ } split( /$separators/, $filename);

	return \@fields;
	
}


1;

__END__

=pod

=head1 NAME

File::Filename - expect a filename to be named by a person to be metadata

=head1 DESCRIPTION

A lot of people use the filename as a place to insert metadata for the file. 
This module has some routines to help with treating those filenames. This code takes into consideration what human beings would name files as.

People often expect a space to be part of something, not a delimeter(as programmers would have it), people see an underscore and it is a separator to them,
but to us it is a "word character".
This is one of a colleciton of modules to help consolidate the real world of file archiving in offices (multiple human users naming files by hand) with the
needs of people maintaining such filesystem hierarchy structures.

=head1 SYNOPSIS

	use File::Filename 'get_filename_segments';
	use Smart::Comments '###';
	
	opendir(DIR,$ENV{HOME});
	
	map { 
		my $segments = get_filename_segments($_); 
		### $segments
	} grep { !/^\.+$/ } readdir DIR;
	
	closedir DIR;
	
=head1 get_filename_segments()

argument is a filename
optional argument is a quoted regex that matches non field characters (separators).
returns array ref

Default regex is qr/[^a-zA-Z0-9 ]+/

If your filenames are x : then they are xplit into y

	x: y
	122706-BRANDYWINE WISCONSIN LLC-005779-@API.pdf : [122706][BRANDYWINE WISCONSIN LLC][005779][API][pdf]
	122706-GUARDIAN REALTY MANAGEMENT INC-005776-@API.pdf : [122706][GUARDIAN REALTY MANAGEMENT INC][005776][API][pdf]
	122705-V & F COFFEE INC-004702-@API.pdf : [122705][V][F COFFEE INC][004702][API][pdf]

Empty segments are not returned.

=head1 SEE ALSO

L<File::Filename::Convention>

=head1 Revision

$Revision: 1.1 $

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut
