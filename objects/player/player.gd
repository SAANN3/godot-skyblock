extends CharacterBody3D
## Class, representing a player.
class_name Player

## A speed, in which players moves.
const PLAYER_SPEED: int = 6
## Sensivity of a mouse inputs.
const SENSIVITY: float = 0.005
## Player range of reach.
const REACH_RANGE: float = 10
## A gravity strength, with player will fall.
const GRAVITY: float = 0.5
## How far will player be able to jump on Y axis.
const JUMP_STRENGTH: float = 15
## Player camera.
@onready
var camera: Camera3D = $"Camera3D"
## A world player interacts within.
var world: Node3D
## Is player flying?
var is_flying: bool = true
## Gravity force, affecting player at moment.
var gravity_force: float = 0
## Stores information about all resources for player.
var resource_system: ResourceSystem
## Items grid.
@onready
var items_grid: GridContainer = $"SubViewport/Control/itemsGrid"
## Current selected item.
var selected_item: BlockResource
## stub Constructor.
func _init() -> void:
	pass

## real constructor, for using when player already has been added to a scene.
func init(resource_system: ResourceSystem, world: Node3D) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == 0 else 0)
	self.resource_system = resource_system
	self.world = world
	# for now primitive items ui.
	for i: String in resource_system.get_resources():
		var block: BlockResource = resource_system.get_resource(i)
		if !selected_item:
			selected_item = block
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(40, 40)
		var texture := TextureRect.new()
		texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		texture.texture = block.texture
		panel.gui_input.connect(func (event: InputEvent) -> void:
			if event.is_action_pressed("lmb"):
				selected_item = block
		)
		panel.add_child(texture)
		$"SubViewport/Control/itemsGrid".add_child(panel)
		


## Tries to raycast and get a block with position of colliding, which can be reached.
func raycast_block() -> OptionalBlockPos:
	var mousepos := get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mousepos)
	var end := origin + camera.project_ray_normal(mousepos) * REACH_RANGE
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty():
		var value: Variant = result["collider"]
		if value is Node3D:
			var staticBody3D: StaticBody3D = value
			var maybe_block := staticBody3D.get_parent()
			if maybe_block.has_meta("self") && maybe_block.get_meta("self") is BlockObject:
				var pos: Vector3 = result["position"]
				var block: BlockObject = maybe_block.get_meta("self")
				return OptionalBlockPos.Some(TupleBlockPos.new(block, pos))
	return OptionalBlockPos.None()

## Creates [CubeHelper] which can be used as analog of current collision shape.
func _to_cube_col() -> CubeHelper:
	var c := CubeHelper.new_from_corner()
	c.scale(Vector3(0.65, 1.75, 0.65))
	c.translate(Vector3(-0.5 * 0.65, -0.85, -0.5 * 0.65))
	c.translate(position)
	return c
	
## Process user inputs.
func _process(delta: float) -> void:
	pass
	
## Process user physics	with inputs.
func _physics_process(delta: float) -> void:
	var texture := preload("res://storage/objects/grass.tres")
	
	if is_on_floor():
		gravity_force = 0
	var user_input := Input.get_vector("left", "right", "forward", "backward")
	velocity = (transform.basis * Vector3(user_input.x, 0, user_input.y)) * PLAYER_SPEED
	if Input.is_action_pressed("jump") && (is_on_floor() || is_flying):
		if is_flying:
			self.translate_object_local(Vector3(0, 1, 0) * PLAYER_SPEED * delta)
		else:
			gravity_force = GRAVITY * JUMP_STRENGTH
	elif Input.is_action_pressed("down"):
		self.translate_object_local(Vector3(0, -1, 0) * PLAYER_SPEED * delta)
	elif Input.is_action_just_pressed("rmb"):
		var opt_block := raycast_block()
		if opt_block.has_value():
			var obj: BlockObject = BlockObject.new(selected_item.id, selected_item.texture)
			var block := opt_block.get_value()
			var new_pos: Vector3 = block.get_1().next_block_pos(block.get_2())
			# Block building inside player
			if !BlockObject.is_colliding_with_box(new_pos, _to_cube_col()):
				obj.place_block(new_pos, world)
			
	elif Input.is_action_pressed("lmb"):
		var opt_block := raycast_block()
		if opt_block.has_value():
			var block := opt_block.get_value()
			block.get_1().break_block()
	
	if Input.is_action_just_pressed("f"):
		gravity_force = 0
		is_flying = !is_flying
	
	if Input.is_action_just_pressed("e"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == 0 else 0)
	
	if !is_flying && !is_on_floor():
		gravity_force = clampf(gravity_force - GRAVITY, -120, 200)
		 
	velocity.y = gravity_force
	move_and_slide()
	
	
	if !is_flying:
		pass
		
## Process user mouse movement.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos: Vector2 = (event as InputEventMouseMotion).relative
		var diff: Vector2 = -pos
		camera.rotation.x = clampf(camera.rotation.x + (diff.y * SENSIVITY), deg_to_rad(-90), deg_to_rad(90))
		rotate_y(diff.x * SENSIVITY)
