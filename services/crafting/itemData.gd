extends Resource

## Structure for storing object and needed amount of it to craft something. 
class_name CraftingRecipeItemData

## An object that will be used in some crafting recipe.
## If null we will try to decide its type based on object, to which this recipes belongs.
## If recipe is not linked to any object this will result an error
@export var object: BasicResource

## Amount of that object, that will be needed.
@export var amount: int = 1
