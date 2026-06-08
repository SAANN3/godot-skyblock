extends Node3D
## A class representing a skyblock world
class_name SkyblockWorld

## Service for storing all resources. 
var _resource_system: ResourceSystem

# Called when the node enters the scene tree for the first time.
## Constructor.
func _ready() -> void:
	_resource_system = ResourceSystem.new() 
	var grass: BlockResource = _resource_system.get_resource("grass")
	var leaf: BlockResource = _resource_system.get_resource("leaf")
	var wood: BlockResource = _resource_system.get_resource("wood")
	# Create island with 3 chunks 3x3.
	for i: int in range(0, 3):
		var offset := Vector3.ZERO
		match i:
			0: offset = Vector3(0, -5, -3)
			1: offset = Vector3(0, -5, 0)
			2: offset = Vector3(-3, -5, 0)
		for x: int in range(0, 3):
			for y: int in range(0, 3):
				for z: int in range(0, 3):
					var obj: BlockObject = BlockObject.new(grass.id, grass.texture)
					obj.place_block(Vector3(x, y, z) + offset, self)
	# Create a tree.
	# trunk.
	for y: int in range(0, 4):
		var obj: BlockObject = BlockObject.new(wood.id, wood.texture)
		obj.place_block(Vector3(2, y - 2, -3), self)
	# leafs
	for y: int in range(0, 4):
		var ring_size := 2 if y < 2 else 1
		for x: int in range(-ring_size, ring_size + 1):
			for z: int in range(-ring_size, ring_size + 1):
				var obj: BlockObject = BlockObject.new(leaf.id, leaf.texture)
				obj.place_block(Vector3(2 + x, y + 2, -3 + z), self)
	pass
	# Spawn player.
	var player: Player = preload("res://objects/player/player.tscn").instantiate()
	add_child(player)
	player.init(_resource_system, $world as Node3D)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
