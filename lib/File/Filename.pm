package File::Filename;
use strict;
require Exporter;
use vars qw(@ISA @EXPORT_OK $VERSION);
@ISA = qw(Exporter);
@EXPORT_OK = (qw(get_filename_segments));
$VERSION = sprintf "%d.%02d", q$Revision: 1.2 $ =~ /(\d+)/g;

$File::Filename::delimiter = qr/[^a-zA-Z0-9 ]+/;

sub get_filename_segments {
	my $filename = shift;
	$filename or warn('get_fields_arrayref() no arg.') and return;	
	my $delimiters = shift;	
	$delimiters ||= 	$File::Filename::delimiter;

   $filename=~s/\/+$//;
	$filename=~s/^.+\/+//; # take out slashes if present
	
	my @fields = 
      map { $_=~s/^\s+|\s+$//g; $_ }
      grep { /./ } # dont use empty elements
      split( /$delimiters/, $filename);

	return \@fields;	
}


1;

__END__

=pod

=head1 NAME

File::Filename - expect a filename to be named by a person to be metadata

=head1 DESCRIPTION

A lot of people use the filename as a place to insert metadata for the file. 
This module has some routines to help with treating those filenames. 
This code takes into consideration what human beings would name files as.

People often expect a space to be *part of* something.
To us, used to the prompt, a space is a delimiter, not a delimeter.

People see an underscore and it is a delimiter to them, but to us it is a "word character".
This is one of a colleciton of modules to help consolidate the real world of file archiving 
in offices (multiple human users naming files by hand) with the
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

argument is a filename, can be absolute path (the location is ignored)
optional argument is a quoted regex that matches non field characters (delimiters).
returns array ref

Default regex is qr/[^a-zA-Z0-9 ]+/

In the below examples, You see the filename, and the resulting elements
 
	122706-BRANDYWINE WISCONSIN LLC-005779-@API.pdf  
   ['122706','BRANDYWINE WISCONSIN LLC','005779','API','pdf']
   
	122706-GUARDIAN REALTY MANAGEMENT INC-005776-@API.pdf 
   [122706','GUARDIAN REALTY MANAGEMENT INC','005776','API','pdf]
   
	122705-V & F COFFEE INC-004702-@API.pdf 
   [122705','V','F COFFEE INC','004702','API','pdf]

What if you wanted the ampersand to be part of word characters?

   $File::Filename::delimiter = qr/[^\&a-zA-Z0-9 ]/;

   # or
   
   get_filename_segments($filename, qr/[^\&a-zA-Z0-9 ]/); 

Empty segments are not returned.

=head1 SEE ALSO

L<File::Filename::Convention>

=head1 Revision

$Revision: 1.2 $

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut
