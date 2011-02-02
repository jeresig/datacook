#!/usr/bin/perl

use JSON;

my $term = $ARGV[0];
my $clean_term = $term;

$clean_term =~ s/ /-/g;

chdir( $clean_term );

my $unit_suffix = qr/(?:piece|\w+\sneeded|(?:for|to|made)[^\(\)]+)/;

my $find_ingredient = qr{
	(
		# The digits to extract (supports: 1, 1 1/4, 1-2)
		^[0-9\/ -]+

		# Any sort of qualifier in parens (for example: 1 (10oz can) green beans)
		(?:\([^\)]+\)\s)?

		# The units themselves
		(?:tablespoons?|tbsps?|tsp|teaspoons?|quart|cups?|pinch|pinches|pounds?|ounces?|oz|cans?|gallons?|bottles?|packages?|pkg|envelopes?|inch|inches|whole|cloves?|heads?|slices?|thin slices?|cubes?|heads?|pieces?|bunch|bunches|dash|dashes|sprigs?|leaf|leaves|head|box|recipe|lbs?|g|kg|each|stars|cakes?|ml|l|fluid\sounces|cm|stalks?|jars?|loaf|loaves|liters?|bags?|drops?)?

		# Unit suffix (sometimes used as the primary unit)
		$unit_suffix?
	)
	\b
}x;

my $find_technique = qr{
	\b(
		# Prefix for action (for example: thinly-sliced)
		(?:
			(?:finely|coarsely|roughly|fully|thinly|lightly|freshly)
			[ -]
		)?

		# The action itself
		(?:chopped|diced|sliced|peeled|deveined|reconstituted|beaten|drained|cubed|cooked|minced|halved|divided|undrained|cut|shredded|crushed|julienned|pitted|boiling|boiled|rinsed|cored|grated|melted|slivered|diagonally|soaked|pat dry|mixed|mashed|dissolved|torn|picked|trimmed|shelled|salted|packed|softened|seeded|cleaned|scaled|\w+\s+removed|\w+\s+left\sin|ground|zested|stemmed|defrosted|toasted|roasted|quartered|flaked|broken\s+up|broken|crumbled|thawed|smashed|deep\sfrying|snipped|washed)

		# The action suffix (for example: sliced thinly)
		(?:
			\s+
			(?:thin|thinly|bite[\s-]*sized|lightly|lengthwise|diagonally|on\sthe\sdiagonal|on\san\sangle|crosswise|each)
		)?

		# The action addendum (for example: sliced into quarters, beaten until tender)
		(?:
			\s+
				(?:into|until|in|with|from)
			\s+
				[^\(\)]+
				#(?= and | or )
		)?
	)
}x;

my $find_size = '(small|large|medium)';

my %extract = (
	"allrecipes.com" => {
		files => 'Recipe/*/Detail.aspx',
		title => '<title>\s*(.*?) Recipe',
		ingredients => '(<div class="ingredients".*?</div>)',
		ingredient => '<li.*?>(.*?)</li>'
	},
	"www.food.com" => {
		files => 'recipe/*',
		title => '<h2 class="fn">\s*(.*?)\s*<',
		ingredients => '(<div class="pod ingredients clrfix".*?<p><strong>)',
		ingredient => '<li.*?>(.*?)</li>'
	},
	"www.recipe.com" => {
		files => '*/index.html',
		title => '<title>(.*?)<',
		ingredients => '(<div class="recipedetailsmore".*?<div class="ACThead3">Directions)',
		ingredient => '<span.*?>(.*?)</span>'
	},
	"chinesefood.about.com" => {
		files => 'od/*/r/*.htm',
		title => '<title>(.*?)<',
		ingredients => '(<h3 id="rI">Ingredients:<\/h3>.*?<\/ul>)',
		ingredient => '<li class="ingredient">(.*?)<\/li>'
	},
);

my @recipes = ();

foreach my $site ( sort keys %extract ) {
	if ( -d $site ) {
		my $opt = $extract{ $site };

		foreach my $name ( glob( $site . "/" . $opt->{files} ) ) {
			my $file = `cat $name`;
			my $recipe = {
				name => "",
				ingredients => {}
			};

			# Extract the recipe title
			if ( $file =~ /$opt->{title}/mi ) {
				$recipe->{ name } = $1;
			}

			# Find the ingredients
			if ( $file =~ m!$opt->{ingredients}!s ) {
				my $ingredients = $1;

				# Get the individual ingredients
				while ( $ingredients =~ m!$opt->{ingredient}!gs ) {
					my ( $name, $data, $otherName, $otherData ) = get_ingredient( $1 );

					if ( $name ) {
						$recipe->{ ingredients }{ $name } = $data;
					}

					if ( $otherName ) {
						$recipe->{ ingredients }{ $otherName } = $otherData;
					}
				}
			}

			push( @recipes, $recipe );
		}
	}
}

print encode_json \@recipes;

sub get_ingredient {
	my $ingredient = clean( lc($_[0]) );
	my $otherName;
	my $otherData;

	if ( $ingredient && $ingredient !~ /:$/ ) {
		if ( $ingredient !~ /\(/ && $ingredient =~ s/ or (\d+.*)$//i ) {
			( $otherName, $otherData ) = get_ingredient( $1 );
		}

		my $data = {};

		if ( $ingredient =~ s!$find_size!!i ) {
			$data->{size} = $1;
		}
					
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
		
		if ( $ingredient =~ s! \(?optional\)?!!i ) {
			$data->{optional} = 1;
		}

		# Clean up stop words
		$ingredient =~ s/\b(?:$unit_suffix|and|or|more|plus|of|will work|is best|if|well|servings|set aside|\w+ parts only|use)\b//g;

		# Remove remaining things in parens
		$ingredient =~ s/\(.*?\)//g;

		return (clean($ingredient), $data, $otherName, $otherData);
	}
}

sub clean {
	my $str = shift;

	$str =~ s/&nbsp;/ /g;
	$str =~ s/&#?[\w\d]+;//g;
	$str =~ s/[*.]//g;
	$str =~ s/(\d+)\s*-\s*(\d+)/\1-\2/gs;
	$str =~ s/^\s*|\s*$//gs;
	$str =~ s/[\s,]+/ /gs;
	$str =~ s/<[^>]+>//g;

	return $str;
}
