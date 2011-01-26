#!/usr/bin/perl

use Data::Dumper;

my $term = $ARGV[0];
my $clean_term = $term;

$clean_term =~ s/ /-/g;

chdir( $clean_term );

my $recipes = {};

if ( -d "allrecipes.com" ) {
	$recipes->{ "allrecipes.com" } = [];

	foreach my $name ( <allrecipes.com/Recipe/*/Detail.aspx> ) {
		my $file = `cat $name`;
		my $recipe = {
			name => "",
			ingredients => {},
			nutrition => {}
		};

		# Find the ingredients
		if ( $file =~ m!(<div class="ingredients".*?</div>)!s ) {
			my $ingredients = $1;

			while ( $ingredients =~ m!<li.*?>(.*?)</li>!gs ) {
				my $ingredient = clean( $1 );

				if ( $ingredient && $ingredient !~ /:$/ ) {
					my $data = {};
					
					if ( $ingredient =~ s!^((?:[0-9/]+(?: [0-9/]+)? (?:tablespoons?|tbsp|tbsps|tsp|teaspoons?|cups?|pinch|pinches|pounds?|ounces?|cans?|gallons?|bottles?))|[0-9/]+(?: \(.*?\))?(?: (?:cans?|gallons?|bottles?))?)!!i ) {
						$data->{unit} = $1;
					}

					if ( $ingredient =~ s! \(?optional\)?!!i ) {
						$data->{optional} = 1;
					}

					$recipe->{ ingredients }{ clean( $ingredient ) } = $data;
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

sub clean {
	my $str = shift;

	$str =~ s/&nbsp;/ /g;
	$str =~ s/&#\d+;//g;
	$str =~ s/^\s*|\s*$//g;
	$str =~ s/\s+/ /g;

	return $str;
}
