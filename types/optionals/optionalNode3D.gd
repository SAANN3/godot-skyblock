extends RefCounted
## An optional value, which can be empty.
class_name OptionalNode3D
## Real stored value.
var _value: Node3D = null
## Bool which represents present of _value.
var _has_value: bool = false

# Creates empty OptionalNode3D
static func None() -> OptionalNode3D:
	return OptionalNode3D.new()

# Creates OptionalNode3D with a data
static func Some(value: Node3D) -> OptionalNode3D:
	var _self := OptionalNode3D.new()
	_self.set_value(value)
	return _self

## Returns value, stored in Optional.
## If value is absent, it will throw an assert error.
func get_value() -> Node3D:
	assert(_has_value, "Optional is None") 
	return _value

## Sets a value, can be null.
func set_value(value: Node3D) -> void:
	_value = value
	_has_value = value != null

## Checks, if Optional has non null value inside of it.
func has_value() -> bool:
	return _has_value
