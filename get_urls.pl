#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use LWP::Simple;
use List::MoreUtils qw(uniq);
use Data::Dumper;

my $term = $ARGV[0];
my $clean_term = $term;
$clean_term =~ s/ /_/g;

unless ( $term ) {
	die "You need to provide a term to search for.";
}

my @urls = ();

my %sites = (
  "allrecipes.com" => {
    resultURL => "http://allrecipes.com/Recipes/world-cuisine/asia/china/ViewAll.aspx?Page=%s",
    pageURL => 'http://allrecipes.com/Recipe/[\w-]+/Detail.aspx',
    minPage => 1,
    maxPage => 10
  },
  "food.com" => {
    resultURL => "http://chinese.food.com/all-recipes/popular?pn=%s",
    pageURL => 'http://www.food.com/recipe/[\w-]+-\d+',
    minPage => 1,
    maxPage => 275
  },
  "recipe.com" => {
    resultURL => "http://www.recipe.com/recipes/china/all/?page=%s",
    pageURL => '/\w+-[\w-]+/',
    minPage => 1,
    maxPage => 11,
    trim => '<div id="allrecipes">.*?<div class="partnersection">',
		prefix => 'http://www.recipe.com'
  },
  "about.com (1)" => {
    resultURL => "http://chinesefood.about.com/od/recipesbymeal/u/easy_chinese_recipes.htm",
    pageURL => 'http://chinesefood.about.com/od/[^/]+/r/[^.]+.htm',
    minPage => 1,
    maxPage => 1
  },
  "about.com (2)" => {
    resultURL => "http://chinesefood.about.com/od/dimsumandpartyrecipes/u/classic_chinese.htm",
    pageURL => 'http://chinesefood.about.com/od/[^/]+/r/[^.]+.htm',
    minPage => 1,
    maxPage => 1
  }
  #"cooks.com" => {
    #resultURL => "http://www.cooks.com/rec/doc/0,1-%s1,chinese,FF.html",
    #pageURL => 'http://www.cooks.com/rec/doc/0,.*?,00.html',
    #minPage => 0,
    #maxPage => 79,
    #trim => 'column1">.*?</TD'
  #}
);

foreach my $site ( keys %sites ) {
	my $opt = $sites{ $site };

	print "Getting $site...\n";

	for ( my $i = $opt->{minPage}; $i <= $opt->{maxPage}; $i++ ) {
		print "  Getting page #$i...\n";

		my $url = $opt->{resultURL};
		$url =~ s/%s/$i/g;

		my $page = get( $url );

		if ( $opt->{trim} ) {
			if ( $page =~ m!($opt->{trim})! ) {
				$page = $1;
			}
		}

		while ( $page =~ m!(["'])($opt->{pageURL})\1!ig ) {
			my $found = $2;
			if ( $opt->{prefix} ) {
				$found = $opt->{prefix} . $found;
			}

			push( @urls, $found );
			print "URL Found: $found\n";
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
