extends RefCounted

## A system for handling storing objects stuff.
class_name InventorySystem

## Stored items within ours. Some items may be null.
## All assumptions will be based on array length. So it should be resized at start.
var _data: Array[InventoryData] = []

## Max items length
var _size: int

## A mapped items for fast-access
## map: key_id = InventoryData
var _mapped_data: Dictionary[String, InventoryData] = {}

## Empty slots that can be filled with any item.
var _empty_slots: int 

## Signal emitted when a cell was changed, can be used for ui subscribing to it.
## Note that it doesnt emitted when amount of some existing item was changed.
## It will be emitted only when we replace a cell InventoryData with new.
signal cell_changed(pos: int, data: InventoryData)

## Constructor
func _init(size: int, data: Array[InventoryData] = []) -> void:
	self._data = data
	self._data.resize(size)
	
	_empty_slots = 0
	## Prepare data.
	for pos: int in range(len(_data)):
			var item: InventoryData = _data[pos]
			if item == null:
				_empty_slots += 1
			else:
				_mapped_data[item.object.id] = item
	self._size = size

## Will add a new object to inventory.
func add_item(object: BasicObject, amount: int = 1) -> void:
	if _mapped_data.has(object.id):
		# TODO handle later max stack amount.
		_mapped_data[object.id].amount += amount
		return
	elif _empty_slots > 0:
		# Maybe optimize instead of looping through inventory(?)
		for pos: int in range(len(_data) - 1, -1, -1):
			var item: InventoryData = _data[pos]
			if item == null:
				_empty_slots -= 1
				_data[pos] = InventoryData.new(object, amount)
				_mapped_data[object.id] = _data[pos]
				cell_changed.emit(pos, _data[pos])
				return
				
	assert(false, "Theres not enough slots!")
	
## Returns inventory size.
func size() -> int:
	return _size

## Checks, if can insert an item into ourself.
func can_insert(object: BasicObject) -> bool:
	# Try to find existing object.
	if _mapped_data.has(object.id):
		# TODO handle later max stack amount.
		return true
	elif _empty_slots > 0:
		return true
	else:
		return false
		
## Get object for given position. 
## May return null, which means that cell is empty.
func get_object(pos: int) -> InventoryData:
	return _data[pos]
	
## Inserts object into given position.
## This function ignores what was previously inside the cell.
func set_object(pos: int, data: InventoryData = null) -> void:
	_data[pos] = data
	cell_changed.emit(pos, data)

## Checks if object with given amount can be taken from inventory.
func can_take(object: BasicObject, amount: int) -> bool:
	if _mapped_data.has(object.id):
		return _mapped_data[object.id].amount >= amount
	else:
		return false
		
## Takes an amount of given object from inventory.
## Assumes that object exists in inventory and its value equal or greater than amout, resulting crash otherwise.
func take(object: BasicObject, amount: int) -> void:
	assert(_mapped_data.has(object.id), "Doesn't have object in inventory!")
	var obj := _mapped_data[object.id]
	assert(obj.amount >= amount, "Doesn't have such great amount.")
	
	obj.amount -= amount
	if obj.amount == 0:
		_mapped_data.erase(object.id)
		# How much of perfomance do we take by sometimes iterating via all full array?
		# If this will become an issue im add position into mapped_data 
		for i: int in range(_size):
			if _data[i] != null && _data[i].object.id == object.id && _data[i].amount == 0:
				set_object(i, null)
				break
