extends Node3D

## A dropped item that can be picked up.
class_name DroppedItem

## preloaded scene.
const _scene = preload("res://objects/scenes/DroppedItem.tscn") 

## Basic object, which will be in this dropped item.
var _obj: BasicObject

## Mesh instance that will be holding our item.
@onready var mesh_instance: MeshInstance3D = $"MeshInstance3D"

## Collision shape.
@onready var col_shape: CollisionShape3D = $"CollisionShape3D"

## Dropped item size in vector.
const ITEM_SIZE: Vector3 = Vector3(0.2, 0.2, 0.2) 
## Randomization factor.
## Offset for position.
const RANDOM_RANGE: float = 0.4

## A constructor that will be called after instancing.
func _initialize(obj: BasicObject) -> void:
	self._obj = obj
	if obj is BlockObject:
		var tmp: BlockObject = obj
		tmp.create_self_node(mesh_instance, ITEM_SIZE)
		var shape := BoxShape3D.new()
		shape.size = ITEM_SIZE
		col_shape.shape = shape
		col_shape.position += ITEM_SIZE / 2
	else:
		assert(false, "Unimplemented type for dropped item")


## Constructor that spawns instantiated scene and places it into world.
static func create(obj: BasicObject, world: Node3D, position: Vector3) -> void:
	var scene: DroppedItem = _scene.instantiate()
	world.add_child(scene)
	scene.global_position = position
	scene.global_position += Vector3(_rand_offset(), _rand_offset(), _rand_offset() )
	scene.rotate_y(deg_to_rad(_rand_offset() * 100))
	scene.rotate_x(deg_to_rad(_rand_offset() * 100))
	scene._initialize(obj)
	
	
## Get randomly offset withing range
static func _rand_offset() -> float:
	return (randf() * RANDOM_RANGE * 2) - RANDOM_RANGE 

## Returns item that we are storing inside, but does not deletes item reference inside.
func view_obj() -> BasicObject:
	return self._obj
	
## Returns item AND deletes item reference, while removing a node3d from scene.
func pick_obj() -> BasicObject:
	assert(self._obj != null, "Tried to pick up an empty object")
	var obj := self._obj
	self._obj = null
	self.queue_free()
	return obj
	
