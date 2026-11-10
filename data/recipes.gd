class_name PizzaRecipes
extends RefCounted

const INGREDIENTS := {
	"dough": {"label": "Dough", "color": Color("d49a4b"), "shape": "dough"},
	"sauce": {"label": "Tomato sauce", "color": Color("d94338"), "shape": "sauce"},
	"mozzarella": {"label": "Mozzarella", "color": Color("fff0bd"), "shape": "cheese"},
	"pepperoni": {"label": "Pepperoni", "color": Color("cc4138"), "shape": "pepperoni"},
	"mushrooms": {"label": "Mushrooms", "color": Color("d9bd91"), "shape": "mushrooms"},
	"pineapple": {"label": "Pineapple", "color": Color("f5c950"), "shape": "pineapple"},
	"ham": {"label": "Ham", "color": Color("e98583"), "shape": "ham"},
	"sausage": {"label": "Sausage", "color": Color("8e4b32"), "shape": "sausage"},
	"herbs": {"label": "Herbs", "color": Color("4c9a58"), "shape": "herbs"},
	"extra_cheese": {"label": "Extra cheese", "color": Color("ffe6a0"), "shape": "extra_cheese"},
}

const RECIPES := [
	{"name": "Pepperoni Classic", "ingredients": ["dough", "sauce", "mozzarella", "pepperoni"]},
	{"name": "Mushroom Pizza", "ingredients": ["dough", "sauce", "mozzarella", "mushrooms", "herbs"]},
	{"name": "Hawaiian", "ingredients": ["dough", "sauce", "mozzarella", "ham", "pineapple"]},
	{"name": "Meat Lovers", "ingredients": ["dough", "sauce", "mozzarella", "pepperoni", "sausage", "ham", "extra_cheese"]},
]

static func ingredient_data(ingredient_id: String) -> Dictionary:
	return INGREDIENTS.get(ingredient_id, INGREDIENTS["dough"])
