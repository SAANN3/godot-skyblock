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
var _camera: Camera3D = $"Camera3D"
## A world player interacts within.
var _world: Node3D
## Is player flying?
var _is_flying: bool = true
## Gravity force, affecting player at moment.
var _gravity_force: float = 0
## Stores information about all resources for player.
var _resource_system: ResourceSystem
## Items grid at bottm.
@onready var _inventory_bar: InventoryBar = $"SubViewport/Control/InventoryBar"
## UiMenu container with tabs and inventory.
@onready var _inventory_menu: Control = $"SubViewport/Control/InventoryMenu"
## Separate inventory ui.
@onready var _inventory_ui: Inventory = $"SubViewport/Control/InventoryMenu/InventoryMenuVbox/Inventory"
## Tab system.
@onready var _inventory_tabs: TabSystem = $"SubViewport/Control/InventoryMenu/InventoryMenuVbox/TabSystem"
## Current selected item. 
var _selected_item_pos: int = -1
	
## items data. May be null.
var _inventory: InventorySystem

## stub Constructor.
func _init() -> void:
	_inventory = InventorySystem.new(INVENTORY_SIZE)

## real constructor, for using when player already has been added to a scene.
func init(resource_system: ResourceSystem, world: Node3D) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == 0 else 0)
	self._resource_system = resource_system
	
	var crafting_tab: CraftingTab = preload("res://ui/tabs/craftingTab.tscn").instantiate()
	_inventory_tabs.insert_tab(crafting_tab, true)
	crafting_tab.init(
		CraftingSystem.new(resource_system.get_resources()), 
		resource_system,
		_inventory
	)
	
	self._world = world
	
	# for now primitive items ui.
	var ids := resource_system.get_ids()
	for i: int in range(len(ids)):
		var block: BasicObject = resource_system.get_object(ids[i])
		_inventory.add_item(block)
		
		
	# Let ui process it by itself. 
	_inventory_ui.init(_inventory, BAR_SIZE)
	_inventory_bar.init(_inventory, BAR_SIZE)
	
	# tmp bar
	var bar_pos := BAR_SIZE - 1
	for i in range(INVENTORY_SIZE - 1, INVENTORY_SIZE - BAR_SIZE - 1, -1):
		var obj: InventoryData = _inventory.get_object(i)
		if _selected_item_pos == -1 && obj:
			_selected_item_pos = i
			_inventory_bar.set_highlight(bar_pos)
		# Tmp ui handling via mouse, later remove and get keyboard support.
		_inventory_bar._slots[bar_pos].clicked.connect(func (event: InventorySlot) -> void:
			var data := _inventory.get_object(i)
			_selected_item_pos = i
			_inventory_bar.set_highlight(bar_pos)
		)
		bar_pos -= 1

## Tries to raycast and get a block with position of colliding, which can be reached.
func raycast_block() -> OptionalBlockPos:
	var mousepos := get_viewport().get_mouse_position()
	var origin := _camera.project_ray_origin(mousepos)
	var end := origin + _camera.project_ray_normal(mousepos) * REACH_RANGE
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty():
		var value: Variant = result["collider"]
		if value is StaticBody3D:
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
	if is_on_floor():
		_gravity_force = 0
	var user_input := Input.get_vector("left", "right", "forward", "backward")
	velocity = (transform.basis * Vector3(user_input.x, 0, user_input.y)) * PLAYER_SPEED
	if Input.is_action_pressed("jump") && (is_on_floor() || _is_flying):
		if _is_flying:
			self.translate_object_local(Vector3(0, 1, 0) * PLAYER_SPEED * delta)
		else:
			_gravity_force = GRAVITY * JUMP_STRENGTH
	elif Input.is_action_pressed("down"):
		self.translate_object_local(Vector3(0, -1, 0) * PLAYER_SPEED * delta)
	elif Input.is_action_just_pressed("rmb") && _get_selected_item():
		var opt_block := raycast_block()
		if opt_block.has_value():
			var obj: BlockObject = (_get_selected_item().object as BlockObject).clone()
			var block := opt_block.get_value()
			var new_pos: Vector3 = block.get_1().next_block_pos(block.get_2())
			# Block building inside player
			if !BlockObject.is_colliding_with_box(new_pos, _to_cube_col()):
				_inventory.take(_get_selected_item().object, 1)
				obj.place_block(new_pos, _world)
			
	elif Input.is_action_pressed("lmb"):
		var opt_block := raycast_block()
		if opt_block.has_value():
			var block := opt_block.get_value()
			block.get_1().break_block()
	
	if Input.is_action_just_pressed("f"):
		_gravity_force = 0
		_is_flying = !_is_flying
	
	if Input.is_action_just_pressed("e"):
		_inventory_menu.visible = !_inventory_menu.visible
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == 0 else 0)
	
	if Input.is_action_just_pressed("q"):
		pass
	
	if !_is_flying && !is_on_floor():
		_gravity_force = clampf(_gravity_force - GRAVITY, -120, 200)
		 
	velocity.y = _gravity_force
	move_and_slide()
	
	if !_is_flying:
		pass
		
## Process user mouse movement.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos: Vector2 = (event as InputEventMouseMotion).relative
		var diff: Vector2 = -pos
		_camera.rotation.x = clampf(_camera.rotation.x + (diff.y * SENSIVITY), deg_to_rad(-90), deg_to_rad(90))
		rotate_y(diff.x * SENSIVITY)

## Allows to pick up a dropped item
func _on_pickup_range_body_entered(body: Node3D) -> void:
	if body is DroppedItem:
		var item: DroppedItem = body
		if _inventory.can_insert(item.view_obj()):
			_inventory.add_item(item.pick_obj())
	
## Returns selected item, may be null.
func _get_selected_item() -> InventoryData:
	return _inventory.get_object(_selected_item_pos)
