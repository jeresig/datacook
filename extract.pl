#!/usr/bin/perl

use Data::Dumper;

my $term = $ARGV[0];
my $clean_term = $term;

$clean_term =~ s/ /-/g;

chdir( $clean_term );

my $units = '(?:tablespoons?|tbsps?|tsp|teaspoons?|quart|cups?|pinch|pinches|pounds?|ounces?|oz|cans?|gallons?|bottles?|packages?|envelopes?|inch|inches|whole|cloves?|heads?|slices?|thin slices?|cubes?|heads?|pieces?|bunch|bunches|dash|dashes|sprigs?|leaf|leaves|head|box|recipe)';
my $find_ingredient = "(^[0-9/ ]+(?:\\([^\\)]+\\) )?$units?(?: piece)?|to taste|as needed|for \\w+|if needed)\\b";

my $find_technique = '\b((?:(?:finely|coarsely|fully|thinly) )?(?:chopped|diced|sliced|peeled|deveined|reconstituted|beaten|drained|cubed|cooked|minced|halved|divided|undrained|cut|shredded|crushed|julienned|pitted|boiling|boiled|rinsed|cored|grated|melted|slivered|diagonally|cut|soaked|mixed|mashed|dissolved|torn|picked|trimmed|shelled|salted|packed|softened|seeded|cleaned|scaled|\w+ removed|finely ground|ground)(?: (?:thin|thinly|lengthwise|diagonally|into .*|until.*|in.*|with.*|from.*))*)\b';

my $find_size = '(small|large|medium)';

my $recipes = {};

if ( -d "allrecipes.com" ) {
	$recipes->{ "allrecipes.com" } = [];

	foreach my $name ( <allrecipes.com/Recipe/*/Detail.aspx> ) {
		my $file = `cat $name`;
		my $recipe = {
			name => "",
			ingredients => {},
			#nutrition => {}
		};

		if ( $file =~ /<title>\s*(.*?) Recipe/mi ) {
			$recipe->{ name } = $1;
		}

		# Find the ingredients
		if ( $file =~ m!(<div class="ingredients".*?</div>)!s ) {
			my $ingredients = $1;

			while ( $ingredients =~ m!<li.*?>(.*?)</li>!gs ) {
				my ( $name, $data ) = get_ingredient( $1 );

				if ( $name ) {
					$recipe->{ ingredients }{ $name } = $data;
				}
			}
		}

		push( @{ $recipes->{ "allrecipes.com" } }, $recipe );
	}
}

$Data::Dumper::Indent = 1;

print Dumper( $recipes );

if ( -d "www.food.com" ) {

}

sub get_ingredient {
	my $ingredient = clean( lc($_[0]) );

	if ( $ingredient && $ingredient !~ /:$/ ) {
		my $data = {};
					
		if ( $ingredient =~ s!$find_ingredient!!i ) {
			$data->{unit} = clean( $1 );
		}

		# Remove any remaining units
		$ingredient =~ s!$find_ingredient!!gi;

		my @techniques = ();

		while ( $ingredient =~ s!$find_technique!!i ) {
			push( @techniques, clean( $1 ) );
		}

		if ( $#techniques > -1 ) {
			$data->{techniques} = \@techniques;
		}
		
		if ( $ingredient =~ s!$find_size!!i ) {
			$data->{size} = $1;
		}

		if ( $ingredient =~ s! \(?optional\)?!!i ) {
			$data->{optional} = 1;
		}

		# Clean up stop words
		$ingredient =~ s/\b(?:and|or|more|plus)\b//g;

		# Remove remaining things in parens
		$ingredient =~ s/\(.*?\)//g;

		return (clean($ingredient), $data);
	}
}

sub clean {
	my $str = shift;

	$str =~ s/&nbsp;/ /g;
	$str =~ s/&#\d+;//g;
	$str =~ s/^\s*|\s*$//g;
	$str =~ s/[, -]+/ /g;
	$str =~ s/<[^>]+>//g;

	return $str;
}
