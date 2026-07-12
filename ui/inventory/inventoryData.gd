extends RefCounted

## A basic struct for inventory data.
class_name InventoryData

## Basic object stored within. 
var object: BasicObject

## Amount of object stored.
var amount: int:
	set(_amount):
		amount = _amount
		amount_changed.emit(_amount)
	get:
		return amount

## Signal, emitted when amount is updated.
signal amount_changed(amount: int)

## Basic constructor
func _init(object: BasicObject, amount: int = 1) -> void:
	self.object = object
	self.amount = amount
	
