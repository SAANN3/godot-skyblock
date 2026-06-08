extends RefCounted
## An optional value, which can be empty.
class_name OptionalBlockPos
## Real stored value.
var _value: TupleBlockPos = null
## Bool which represents present of _value.
var _has_value: bool = false

# Creates empty OptionalBlockPos
static func None() -> OptionalBlockPos:
	return OptionalBlockPos.new()

# Creates OptionalBlockPos with a data
static func Some(value: TupleBlockPos) -> OptionalBlockPos:
	var _self := OptionalBlockPos.new()
	_self.set_value(value)
	return _self

## Returns value, stored in Optional.
## If value is absent, it will throw an assert error.
func get_value() -> TupleBlockPos:
	assert(_has_value, "Optional is None") 
	return _value

## Sets a value, can be null.
func set_value(value: TupleBlockPos) -> void:
	_value = value
	_has_value = value != null

## Checks, if Optional has non null value inside of it.
func has_value() -> bool:
	return _has_value
