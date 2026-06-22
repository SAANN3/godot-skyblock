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
## Size of slots, that will be accounted in ui parts.
const BAR_SIZE: int = 10
## Inventory size.
const INVENTORY_SIZE: int = 4 * BAR_SIZE
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
## Items grid at bottm.
@onready var inventory_bar: InventoryBar = $"SubViewport/Control/InventoryBar"
## Separate inventory ui.
@onready var inventory_ui: Inventory = $"SubViewport/Control/Inventory"
## Current selected item. May be null.
var selected_item: BasicObject
## 
## items data. May be null.
var inventory_data: Array[BasicObject] = [] 

## stub Constructor.
func _init() -> void:
	inventory_data.resize(INVENTORY_SIZE)

## real constructor, for using when player already has been added to a scene.
func init(resource_system: ResourceSystem, world: Node3D) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == 0 else 0)
	self.resource_system = resource_system
	self.world = world
	
	inventory_ui.inventory_cell_changed.connect(_on_inventory_cell_changed)
	# for now primitive items ui.
	var ids := resource_system.get_ids()
	for i: int in range(len(ids)):
		var block: BasicObject = resource_system.get_object(ids[i])
		inventory_data[len(inventory_data) - i - 1] = block
		
		
	# May ui process it by itself. 
	inventory_ui.init(inventory_data, BAR_SIZE)
	# Tmp bar init.
	for i in len(inventory_data.slice(-BAR_SIZE)):
		var obj: BasicObject = inventory_data.slice(-BAR_SIZE)[i]
		inventory_bar.set_object(i, obj)
		if !selected_item && obj:
			selected_item = obj
			inventory_bar.set_highlight(i)
		# Tmp ui handling via mouse, later remove and get keyboard support.
		inventory_bar.slots[i].gui_input.connect(func (event: InputEvent) -> void:
			if event.is_action_pressed("lmb"):
				selected_item = inventory_data.slice(-BAR_SIZE)[i]
				inventory_bar.set_highlight(i)
		)
		

## Notified when in inventory ui obj was changed(Like created, moved, etc...).
## 'obj' may be null.
func _on_inventory_cell_changed(pos: int, obj: BasicObject) -> void:
	inventory_data[pos] = obj
	# Check if we should update bottom bar.
	var right_items_len := len(inventory_data) - pos
	if right_items_len <= BAR_SIZE:
		var bar_pos := BAR_SIZE - right_items_len
		inventory_bar.set_object(bar_pos, obj)

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
	elif Input.is_action_just_pressed("rmb") && selected_item:
		var opt_block := raycast_block()
		if opt_block.has_value():
			var obj: BlockObject = BlockObject.new(selected_item.id, selected_item.slot_texture())
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
		inventory_ui.visible = !inventory_ui.visible
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
