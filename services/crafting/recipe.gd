extends Resource

## Structure for defining single crafting reicpe.
class_name CraftingRecipe

## Array of resources, that will be used to fulfuill this recipe.
@export var items: Array[CraftingRecipeItemData] = []

## Item that we will produce as output, with amount.
## If null, then, if attached to object, will be filled with it, otherwise resulting an error.
@export var out_item: CraftingRecipeItemData = null
