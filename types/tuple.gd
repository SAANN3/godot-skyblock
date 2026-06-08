extends RefCounted
## A Non modifiable tuple holding two values.  
class_name Tuple2D

## First value of tuple.
var _1: Variant = null
## Second value of tuple.
var _2: Variant = null

## Init constructor.
func _init(_1: Variant, _2: Variant) -> void:
	self._1 = _1
	self._2 = _2
	
## Returs first variable of tuple.
func get_1() -> Variant:
	return _1
	
## Returs second variable of tuple.
func get_2() -> Variant:
	return _2
