extends RefCounted
## A class representing an abstract object, that can be interacted with.
class_name BasicObject

## Object id.
var id: String

## Init a normal object.
func _init(id: String) -> void:
	self.id = id

## Returns texture, which will be used for a slot ui.
func slot_texture() -> Texture2D:
	assert(false, "unimplemented!")
	return null

## 'Drops' item in the 'world'. 
## world - Where we drop an item.
## direction - in which direction should item drop.
## position - at which position object should be created
func drop(world: Node3D, direction: Vector3, position: Vector3) -> void:
	DroppedItem.create(self, world, position)
