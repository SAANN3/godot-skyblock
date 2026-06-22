extends RefCounted
## An optional value, which can be empty.
class_name OptionalBasicObject
## Real stored value.
var _value: BasicObject = null
## Bool which represents present of _value.
var _has_value: bool = false

# Creates empty OptionalBasicObject
static func None() -> OptionalBasicObject:
	return OptionalBasicObject.new()

# Creates OptionalBasicObject with a data
static func Some(value: BasicObject) -> OptionalBasicObject:
	var _self := OptionalBasicObject.new()
	_self.set_value(value)
	return _self

## Returns value, stored in Optional.
## If value is absent, it will throw an assert error.
func get_value() -> BasicObject:
	assert(_has_value, "Optional is None") 
	return _value

## Sets a value, can be null.
func set_value(value: BasicObject) -> void:
	_value = value
	_has_value = value != null

## Checks, if Optional has non null value inside of it.
func has_value() -> bool:
	return _has_value
