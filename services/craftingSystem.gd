extends RefCounted

## System that manages crafting recipes.
class_name CraftingSystem

## Mapped data for fast access. 
## Key - object id, value - Array of crafting recipes. 
var _data: Dictionary[String, Array] = {}

## Constructor. Creates crafting recipes for given mapped dict of objects.
## Dict should be id - obj.
func _init(objects: Dictionary[String, BasicResource] ) -> void:
	for i: String in objects:
		var object := objects[i]
		for recipe: CraftingRecipe in object.craft_recipes:
			if recipe.out_item == null:
				recipe.out_item = CraftingRecipeItemData.new() 
				recipe.out_item.object = object
			elif recipe.out_item.object == null:
				recipe.out_item.object = object
			_insert_recipe(recipe)



## Inserts crafting reicpe to our iternal data collection.
func _insert_recipe(recipe: CraftingRecipe) -> void:
	assert(recipe.out_item != null && recipe.out_item.object != null, "Out item is null")
	var out_id := recipe.out_item.object.id
	if _data.has(out_id):
		_data[out_id].append(recipe)
	else:
		_data[out_id] = [recipe]

## Returns all recipes for given item.
func get_recipes(object_id: String) -> Array[CraftingRecipe]:
	return _data[object_id] if _data.has(object_id) else [] 

## Returns all objects ids that may be crafted.
func get_possible_objects() -> Array[String]:
	return _data.keys()
