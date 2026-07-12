extends BasicObject
## An block that could be mined, placed, and stored.
class_name BlockObject
## Length(size) from one side of a block to another.
const BLOCK_SIZE: int = 1
## Length(size) from a side to the center.
## This constant is calculated from [constant BLOCK_SIZE].
const BLOCK_SIZE_FROM_CENTER: float = BLOCK_SIZE as float / 2
## Variable, in which Node3D instance will be stored.
var _object := OptionalNode3D.new()
## Can this block be dropped after mining?
var _droppable: bool = false
## Texture of object.
var _texture: Texture2D
## A constructor for a block object.
func _init(id: String, texture: Texture2D, droppable: bool) -> void:
	self._texture = texture
	self._droppable = droppable
	super(id)
	
## Clones block, creating new instance of it.
func clone() -> BlockObject:
	return BlockObject.new(id, _texture, _droppable)
	
# Switched to using Vector3i because Vector3 with floats gives rounding errors.

## Creates self mesh node, which can be used whatever we want.
## Either block or as dropped item.
func create_self_node(
	mesh_container: MeshInstance3D,
	node_size: Vector3 = Vector3(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
) -> Node3D:
	var block: MeshInstance3D = mesh_container
	var material3d := StandardMaterial3D.new()
	material3d.albedo_texture = _texture
	block.material_override = material3d
	var helper := CubeHelper.new_from_corner()
	helper.scale(node_size)
	block.mesh = helper.to_surface_struct().compile()
	
	return block

## Creates block and append colission shapes into it.
func _create_self_node_w_colission(
	mesh: MeshInstance3D) -> Node3D:
	var block := create_self_node(mesh)
	# Collision.
	var staticBody := StaticBody3D.new()
	var shape3D := CollisionShape3D.new()
	var boxShape := BoxShape3D.new()
	boxShape.size = Vector3(BLOCK_SIZE_FROM_CENTER * 2, BLOCK_SIZE_FROM_CENTER * 2, BLOCK_SIZE_FROM_CENTER * 2)
	shape3D.shape = boxShape
	# Move position of a child, so collision matches actual block
	shape3D.position = Vector3(BLOCK_SIZE_FROM_CENTER, BLOCK_SIZE_FROM_CENTER, BLOCK_SIZE_FROM_CENTER)
	staticBody.add_child(shape3D)
	block.add_child(staticBody)
	return block

## Places a block in given coordinates and sets its parent to a 'parent'.
func place_block(pos: Vector3i, parent: Node3D) -> void:
	assert(!_object.has_value(), "Tried to place already existing block")
	var block := self._create_self_node_w_colission(preload("res://objects/scenes/block.tscn").instantiate() as MeshInstance3D)
	# Attach 'self' as metadata to a node3D block.
	# I don't want to create a separate script, just to put it in Block.
	block.set_meta("self", self)
	
	block.position = pos
	parent.add_child(block)
	_object.set_value(block)
	
## Destroys a block.
## A Node3D, which represents current block will be deleted immediately freed.
func break_block() -> void: 
	var block := _object.get_value()
	if _droppable:
		var offset := block.position + Vector3(BLOCK_SIZE_FROM_CENTER, BLOCK_SIZE_FROM_CENTER, BLOCK_SIZE_FROM_CENTER)
		drop(block.get_parent_node_3d(), Vector3(0, 0, 0), offset)
	
	block.free()
	_object.set_value(null)

## Hides/Shows block in world.
## It doesn't unloads an object, it just hides it, for perfomance reasons.
func set_visible(visible: bool) -> void:
	pass
	
## Get next possible block position, relative to this block, that will be a best fit for given point in space.
func next_block_pos(pos: Vector3) -> Vector3i:
	var current_center: Vector3 = _object.get_value().position
	var diff: Vector3 = pos - current_center
	var abs_diff: Vector3 = diff.abs()
	
	# The first one that will be a aproximately an int, will be or selected side.
	if Primitives.is_int(abs_diff.y):
		if !is_zero_approx(diff.y):
			return current_center + Vector3(0, BLOCK_SIZE, 0)
		else:
			return current_center - Vector3(0, BLOCK_SIZE, 0)
	if Primitives.is_int(abs_diff.z):
		if !is_zero_approx(diff.z):
			return current_center + Vector3(0, 0, BLOCK_SIZE)
		else:
			return current_center - Vector3(0, 0, BLOCK_SIZE)
	if Primitives.is_int(abs_diff.x):
		if !is_zero_approx(diff.x):
			return current_center + Vector3(BLOCK_SIZE, 0, 0)
		else:
			return current_center - Vector3(BLOCK_SIZE, 0, 0)
	
	assert(false, "Couldn't place a block, impossible condition.")
 	# Fallback. Not leaving 'else' above in case this thing will break.
	return current_center + Vector3(0, BLOCK_SIZE, 0)
	
## Checks if a box with given coordinates and shape could collide with block at given position.
static func is_colliding_with_box(obj_pos: Vector3, cube: CubeHelper) -> bool:
	var p := CubeHelper.new_from_corner()
	p.translate(obj_pos)
	return p.intersects_with_cube(cube)

## Returns texture, which will be used for a slot ui.
func slot_texture() -> Texture2D:
	return _texture
