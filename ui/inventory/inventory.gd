extends Control

## Inventory ui.
class_name Inventory

## Slots container for main inventory.
@onready var _slot_container: GridContainer = $"VBoxContainer/Slots"
## Slots container for bottom bar.
@onready var _bar_slot_container: GridContainer = $"VBoxContainer/bar"
## Slots for inventory.
@onready var _inventory_slots: Array[InventorySlot] = []
## Struct data, for pairing slot and its position.
class SlotInfo:
	var slot: InventorySlot
	var position: int
	var amount: int
	func _init(slot: InventorySlot, position: int, amount: int) -> void:
		self.slot = slot
		self.position = position
		self.amount = amount
		
## Selected slot that we are currently holding.
var currently_holding: SlotInfo = null
## A signal emitted when a cell was modified from ui side.
## Returns position of cell and obj, that currently inside of it.
## Obj can be null.
signal inventory_cell_changed(pos: int, obj: InventoryData)

## Init, after we already have been added to the scene.
## 'inventory' - current user inventory state from which we will create a ui slots.
func init(inventory: InventorySystem, bar_size: int) -> void:
	var inventory_len: int = inventory.size()
	# create slots.
	var scene := preload("res://ui/inventory/inventorySlot.tscn")
	if inventory_len - bar_size > 0:
		for i in range(inventory_len - bar_size):
			var slot: InventorySlot = scene.instantiate()
			_slot_container.add_child(slot)
			_inventory_slots.append(slot)
		for i in range(bar_size):
			var slot: InventorySlot = scene.instantiate()
			_bar_slot_container.add_child(slot)
			_inventory_slots.append(slot)
	else:
		for i in range(bar_size - inventory_len):
			var slot: InventorySlot = scene.instantiate()
			_bar_slot_container.add_child(slot)
			_inventory_slots.append(slot)
	# Fill them.
	for i in range(inventory_len):
		set_inventory_object(i, inventory.get_object(i))
	
## Sets objects for slot in bar.
## 'object' may be null.
func set_inventory_object(pos: int, object: InventoryData) -> void:
	_inventory_slots[pos].set_object(object)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lmb"):
		var mouse_slot := _mouse_inside_slot()
		if mouse_slot:
			currently_holding = mouse_slot
			mouse_slot.slot.set_drag_mode(true)
	elif Input.is_action_pressed("lmb"):
		if currently_holding:
			var slot_ui := currently_holding.slot.get_ui_object()
			slot_ui.global_position = get_global_mouse_position()
	elif Input.is_action_just_released("lmb"):
		var mouse_slot := _mouse_inside_slot()
		if currently_holding:
			currently_holding.slot.set_drag_mode(false)
			if mouse_slot && mouse_slot.slot != currently_holding.slot:
				var next_object := mouse_slot.slot.get_object()					
				mouse_slot.slot.set_object(currently_holding.slot.get_object())
				currently_holding.slot.set_object(next_object)
				inventory_cell_changed.emit(mouse_slot.position, mouse_slot.slot.get_object())
				inventory_cell_changed.emit(currently_holding.position, currently_holding.slot.get_object())
			currently_holding = null
		
	
## Calculates in which slot mouse currently is. May return null.
func _mouse_inside_slot() -> SlotInfo:
	var mouse_pos := get_global_mouse_position()
	for i: int in range(len(_inventory_slots)):
		var item := _inventory_slots[i]
		if item.get_global_rect().has_point(mouse_pos):
			return SlotInfo.new(item, i, 1)
	
	return null
