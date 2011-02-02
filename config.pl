%sites = (
	"allrecipes.com" => {
		resultURL => "http://allrecipes.com/Recipes/world-cuisine/asia/china/ViewAll.aspx?Page=%s",
		pageURL => 'http://allrecipes.com/Recipe/.*?/Detail.aspx',
		minPage => 1,
		maxPage => 10
	},
	"food.com" => {
		resultURL => "http://chinese.food.com/all-recipes/popular?pn=%s",
		pageURL => 'http://www.food.com/recipe/.*?-\d+',
		minPage => 1,
		maxPage => 275
	},
	"recipe.com" => {
		resultURL => "http://www.recipe.com/recipes/china/all/?page=%s",
		pageURL => 'http://www.recipe.com/[\w-]+/',
		minPage => 1,
		maxPage => 11,
		trim => '<div id="allrecipes">.*?<div class="pagination'
	},
	"about.com (1)" => {
		resultURL => "http://chinesefood.about.com/od/recipesbymeal/u/easy_chinese_recipes.htm",
		pageURL => 'http://chinesefood.about.com/od/.*?/r/.*?.htm',
		minPage => 1,
		maxPage => 1
	},
	"about.com (2)" => {
		resultURL => "http://chinesefood.about.com/od/dimsumandpartyrecipes/u/classic_chinese.htm",
		pageURL => 'http://chinesefood.about.com/od/.*?/r/.*?.htm',
		minPage => 1,
		maxPage => 1
	},
	"cooks.com" => {
		resultURL => "http://www.cooks.com/rec/doc/0,1-%s,chinese,FF.html",
		pageURL => 'http://www.cooks.com/rec/doc/0,.*?,00.html',
		minPage => 0,
		maxPage => 79,
		trim => 'column1">.*?</TD'
	}
);
