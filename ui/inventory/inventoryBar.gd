extends Control

## Ui inventory bar that player will see at the bottom.
class_name InventoryBar

## Ui slots.
var _slots: Array[InventorySlot] = []

## Position of current highlight.
var _highlighted_element: int = -1

## Slots container
@onready var _container: HBoxContainer = $"slots"

## Inventory
var _inventory: InventorySystem

## Init ui.
func _ready() -> void:
	pass

## Init, after we already have been added to the scene.
## 'inventory' - current user inventory state from which we will create a ui slots.
func init(inventory: InventorySystem, bar_size: int) -> void:
	_inventory = inventory
	_inventory.cell_changed.connect(set_inventory_data)
	var scene := preload("res://ui/inventory/inventorySlot.tscn")
	for i in range(bar_size):
		var slot: InventorySlot = scene.instantiate()
		_container.add_child(slot)
		_slots.append(slot)
		
	for i in range(inventory.size() - 1, inventory.size() - bar_size - 1, -1):
		var obj: InventoryData = inventory.get_object(i)
		_slots[bar_size - (inventory.size() - i)].set_inventory_data(obj)


## Highlights slot at given position, while removing hihglight from previous slot.
func set_highlight(pos: int) -> void:
	if _highlighted_element != -1:
		_slots[_highlighted_element].set_highlight(false)
	_highlighted_element = pos
	_slots[pos].set_highlight(true)
 
## Sets objects for slot
func set_inventory_data(pos: int, object: InventoryData = null) -> void:
	pos = _inventory.size() - pos
	if (pos) <= _slots.size():
		_slots[_slots.size() - pos].set_inventory_data(object)
