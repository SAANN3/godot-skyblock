extends RefCounted
## An optional value, which can be empty.
class_name OptionalVariant
## Real stored value.
var _value: Variant = null
## Bool which represents present of _value.
var _has_value: bool = false

# Creates empty OptionalVariant
static func None() -> OptionalVariant:
	return OptionalVariant.new()

# Creates OptionalVariant with a data
static func Some(value: Variant) -> OptionalVariant:
	var _self := OptionalVariant.new()
	_self.set_value(value)
	return _self

## Returns value, stored in Optional.
## If value is absent, it will throw an assert error.
func get_value() -> Variant:
	assert(_has_value, "Optional is None") 
	return _value

## Sets a value, can be null.
func set_value(value: Variant) -> void:
	_value = value
	_has_value = value != null

## Checks, if Optional has non null value inside of it.
func has_value() -> bool:
	return _has_value
