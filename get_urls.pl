#!/usr/bin/perl

use LWP::Simple;
use List::MoreUtils qw(uniq);
use Data::Dumper;

my $term = $ARGV[0];
my $clean_term = $term;
$clean_term =~ s/ /_/g;

unless ( $term ) {
	die "You need to provide a term to search for.";
}

require "config.pl";

my @urls = ();

foreach my $site ( keys %sites ) {
	my @urls = ();
	my $opt = $sites{ $site };

	print "Getting $site...\n";

	for ( my $i = $opt->{minPage}; $i <= $opt->{maxPage}; $i++ ) {
		print "  Getting page #$i...\n";
		my $page = get( $opt->{resultURL} . $i );

		while ( $page =~ m!($opt->{pageURL})!g ) {
			push( @urls, $1 );
		}

		sleep( 3 );
	}
}

print "Uniquing found URLs...\n";
@urls = uniq( @urls );

print "Writing out results.\n";

mkdir( $clean_term );

open( F, ">$clean_term/urls.txt" );
print F join( "\n", @urls );
close( F );

print "Retreiving pages...\n";

chdir( $clean_term );

`wget --wait=2 --random-wait -x --input-file=urls.txt`
