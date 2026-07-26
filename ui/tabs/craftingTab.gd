extends BasicTab

## Tab which allows player to craft various items.
class_name CraftingTab

## Crafting system.
var _crafting_system: CraftingSystem

## Resource system.
var _resource_system: ResourceSystem

## Player inventory.
var _player_inventory: InventorySystem

## List of objects that can be crafted
@onready var _crafting_list: VBoxContainer = $"VBoxContainer/Objects/VBoxContainer/CraftingObjects"

## List of crafting recipes for given object 
@onready var _recipes_list: VBoxContainer = $"VBoxContainer/Recipes/VBoxContainer/RecipesList"

## An example of recipe that we will reuse 
@onready var _recipe_tmp: Control = $"VBoxContainer/Recipes/VBoxContainer/RecipesList/tmp"


## Constructor. Should be used after adding tab to scene.
func init(
	crafting_system: CraftingSystem, 
	resource_system: ResourceSystem,
	player_inventory: InventorySystem
) -> void:
	_crafting_system = crafting_system
	_resource_system = resource_system
	_player_inventory = player_inventory
	
	for i: String in _crafting_system.get_possible_objects():
		_insert_crafting_object(_resource_system.get_resource(i))
	
## Inserts an object into crafting list menu.
func _insert_crafting_object(object: BasicResource) -> void:
	var slot: InventorySlot = preload("res://ui/inventory/inventorySlot.tscn").instantiate()
	_crafting_list.add_child(slot)
	slot.set_object(_resource_system.get_object(object.id))
	slot.set_amount_visibility(false)
	slot.clicked.connect(_on_object_clicked)

## Inserts crafting recipe for specific object.
func _insert_crafting_recipe(recipe: CraftingRecipe) -> void:
	var node: Control = _recipe_tmp.duplicate()
	node.show()
	_recipes_list.add_child(node)

	var container: GridContainer = node.get_node("itemsContainer")
	for i in container.get_children():
		i.queue_free()
	
	for i in recipe.items:
		var slot: InventorySlot = preload("res://ui/inventory/inventorySlot.tscn").instantiate()
		container.add_child(slot)
		slot.set_object(_resource_system.get_object(i.object.id), i.amount)
		
	var out: InventorySlot = node.get_node("output")
	out.set_object(_resource_system.get_object(recipe.out_item.object.id), recipe.out_item.amount)
	out.clicked.connect(func (x: InventorySlot) -> void:
		_on_recipe_clicked(recipe)
	)

## Clears recipes list.
func _clear_recipes_list() -> void:
	for i in _recipes_list.get_children():
		if i.name != _recipe_tmp.name:
			i.queue_free()

## Triggered when object was clicked in object list.
func _on_object_clicked(slot: InventorySlot) -> void:
	# There's no point in empty object inside recipes list.
	var object_id := slot.get_inventory_data().object.id
	_clear_recipes_list()
	for i: CraftingRecipe in _crafting_system.get_recipes(object_id):
		_insert_crafting_recipe(i)
		
## Triggered when object recipe was selected.
func _on_recipe_clicked(recipe: CraftingRecipe) -> void:
	var can_craft: bool = true
	for i in recipe.items:
		var object := _resource_system.get_object(i.object.id)
		var amount := i.amount
		if !_player_inventory.can_take(object, amount):
			can_craft = false
			break
	
	if !can_craft:
		return
	
	for i in recipe.items:
		var object := _resource_system.get_object(i.object.id)
		var amount := i.amount
		_player_inventory.take(object, amount)
		
	_player_inventory.add_item(_resource_system.get_object(recipe.out_item.object.id), recipe.out_item.amount)
