package File::Filename::Convention;
use strict;
use File::Filename 'get_filename_segments';
require Exporter;
use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = (qw(get_filename_hash));


our $VERSION = sprintf "%d.%02d", q$Revision: 1.4 $ =~ /(\d+)/g;
$File::Filename::Convention::DEBUG = 0;
sub DEBUG : lvalue { $File::Filename::Convention::DEBUG }


sub get_filename_hash {
	my $filename = shift;
	my $filenamingconvention_fields = shift;
	my $filenamingconvention_matchsubs = shift;

	my $segments =get_filename_segments($filename);


	my $try=0;

	
	CONVENTION :
	for (@{$filenamingconvention_fields}){
		my $convention = $_;



		printf STDERR " CONVENTION MATCH ... try %s \n", ++$try if DEBUG;
		
		scalar @$convention == scalar @$segments or next;

		my $x=0;
		my $segment_hash={};	
		
		for(@$convention) {
			my $segmentlabel = $_;
			my $segmentcontent = @$segments[$x++];

			print STDERR "$segmentlabel:$segmentcontent\n" if DEBUG;
			
			defined $segmentlabel or next CONVENTION;

			print STDERR "was def.. \n" if DEBUG;
			
			my $mustbe;
			if (ref $segmentlabel eq 'ARRAY'){
			
				print STDERR " - was array [$segmentlabel]\n" if DEBUG;
			
				($segmentlabel,$mustbe) = @$segmentlabel;
				print STDERR " - split into.. [$segmentlabel] must be [$mustbe]\n" if DEBUG;	
			}


			if (defined $filenamingconvention_matchsubs->{$segmentlabel}){

				print STDERR " has sub?\n" if DEBUG;
				
				&{$filenamingconvention_matchsubs->{$segmentlabel}}($segmentcontent) or do {
					print STDERR "sub $segmentlabel returns no for $segmentcontent\n" if DEBUG;
					next CONVENTION;
				};	

				print STDERR " had sub, yes..\n" if DEBUG;

				if(defined $mustbe){
					print STDERR " mustbe $mustbe\n" if DEBUG;
					$segmentcontent=~/^$mustbe$/i or next CONVENTION;
					print STDERR "is\n" if DEBUG;
				}

				$segment_hash->{$segmentlabel} = $segmentcontent;
				next; 
			}

			$segment_hash->{$segmentlabel} = $segmentcontent;		
		}



		return $segment_hash;	
	}

	print STDERR "filename $filename matches no convention, tried $try kinds" if DEBUG;
	return ;

}

1;

__END__

=pod

=head1 NAME

File::Filename::Convention - test a filename against a file naming convention

=head1 SYNOPSIS

	use File::Filename::Convention 'get_filename_hash';

	my $filename = 'James Edward-2007.txt';
	my $metadata = get_filename_hash($filename,[[qw(name year ext)]]);
	
	for (keys %$metadata){
		print "$_ is $$metadata{$_}\n";
	}

=head1 DESCRIPTION

=head1 get_filename_hash()

	my $hash = get_filename_hash(
		$filename,
		['city','state'],
		{
			state => sub { qr /^MD$|^VA$|^NY$/ }, # only states MD, VA, nad NY will be valid for us
		}
	);

This would only return a hash if a file is named 'city' (a string) and one of the states NY, MD or VA.

The following $filename(s) would match and return a hash ref:

	Silver Spring-MD.txt
	Waynesboro-VA.txt
	Saratoga Springs-NY.txt

They would return:

	{ city => 'Silver Spring', state => 'MD' },
	{ city => 'Waynesboro', state => 'VA' },
	{ city => 'Saratoga Springs', state => 'NY' },

The following filenames would NOT match:

	Silver Spring.txt
	VA-Waynesboro.txt
	Saratoga Springs-NY-3.txt

Thus they would not return a hash ref, they would return undef.
	

=head1 EXAMPLE

Let's say that we have a file naming convention that has two kinds of files.

The first kind of file is a 'map' file, for which in the filename, we could place the author, and the date it was created.
For convenience, we will also use a 'code' in this filename, the code will be 'MAP'.
For 'MAP' files, imagine we want to always have the date first, then the author, then the code, finally the extension.

	20070731-John G Reggie-MAP.pdf
	20070731.John G Reggie.MAP.pdf
	20070731_John G Reggie_MAP.pdf
	20070731#John G Reggie@MAP.pdf
	

The second kind of file is a 'layout' file. In the filename we expect to have also the 'author' a date, and also a building code.
The code for this type will be 'LAY'.
For these 'LAY' files, we want to have the author first, and then the date, the building code, finally the file naming convention code and the extension.
So valid filenames would be:

	John G Reggie-20070816-B34-LAY.pdf
	John G Reggie.20070816.B34.LAY.pdf
	John G Reggie_20070816_B34_LAY.pdf
	John G Reggie#20070816@B34-LAY.pdf
	

Here's how we would enforce this file naming convention:

	my $fields= [
		['date','author','code','ext'], # for MAP	
		['author','date','building_code','code','ext'],	# for LAY	
		['date','ext'], # notes files
	];

	my $matchsubs = {
		date => sub { qr/\d{6,8}/ },
		code => sub { qr/^LAY$|^MAP$/ },
		building_code => sub { qr/^B\d+$/ },
	};


Let's imagine we loaded a list of filenames:

	my @filenames = (
	'20070731-John G Reggie-MAP.pdf',
	'20070731John G Reggie-MAP.pdf',	
	'20070731-John G Reggie-MAP.pdf',
	'John G Reggie_20070816_B34_LAY.pdf',
	'John Jeff Notes 1.txt',	
	);

Now let's check those..

	for (@filenames){
		my $hash = get_filename_hash($_, $fields, $matchsubs);
	
		### $_
		### $hash
	}

As you will see, two files do not match our convention.

What if you want to make sure that the codes and extensions match as you wish?

	my $fields= [
		['date','author','code'=> 'MAP', 'ext'=> 'pdf'], # for MAP	
		['author','date','building_code','code' => 'LAY','ext' => 'pdf'],	# for LAY	
		['date','ext' => 'txt'], # notes files
	];

This will match case insensitive.


=head1 SEE ALSO

L<File::Name>

=head1 Revision

$Revision: 1.4 $

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut
