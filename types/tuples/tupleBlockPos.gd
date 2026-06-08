extends RefCounted
## A Non modifiable tuple holding two values.  
class_name TupleBlockPos

## First value of tuple.
var _1: BlockObject = null
## Second value of tuple.
var _2: Vector3 = Vector3.ZERO

## Init constructor.
func _init(_1: BlockObject, _2: Vector3) -> void:
	self._1 = _1
	self._2 = _2
	
## Returs first variable of tuple.
func get_1() -> BlockObject:
	return _1
	
## Returs second variable of tuple.
func get_2() -> Vector3:
	return _2
