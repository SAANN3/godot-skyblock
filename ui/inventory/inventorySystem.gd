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
func add_item(object: BasicObject) -> void:
	if _mapped_data.has(object.id):
		# TODO handle later max stack amount.
		_mapped_data[object.id].amount += 1
		return
	elif _empty_slots > 0:
		# Maybe optimize instead of looping through inventory(?)
		for pos: int in range(len(_data) - 1, -1, -1):
			var item: InventoryData = _data[pos]
			if item == null:
				_empty_slots -= 1
				_data[pos] = InventoryData.new(object, 1)
				_mapped_data[object.id] = _data[pos]
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
## This function ignores what was inside cell previously.
func set_object(pos: int, data: InventoryData = null) -> void:
	_data[pos] = data
