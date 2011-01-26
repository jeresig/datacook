my %sites = (
	"allrecipes.com" => {
		resultURL => "http://allrecipes.com/Search/Recipes.aspx?WithTerm=$term&Page=",
		pageURL => 'http://allrecipes.com/Recipe/.*?/Detail.aspx',
		minPage => 1,
		maxPage => 10
	},
	"food.com" => {
		resultURL => "http://www.food.com/recipe-finder/all/$term?pn=",
		pageURL => 'http://www.food.com/recipe/.*?-\d+',
		minPage => 1,
		maxPage => 10,
	}
);
