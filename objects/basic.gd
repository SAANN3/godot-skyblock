extends RefCounted
## A class representing an abstract object, that can be interacted with.
class_name BasicObject

## Object id.
var _id: String

## Init a normal object.
func _init(id: String) -> void:
	_id = id
