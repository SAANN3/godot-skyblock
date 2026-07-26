extends Control
## Slot class for cell inventory system.
class_name InventorySlot

## Texture rect, which stores a texture.
@onready var _texture_rect: TextureRect = $"PanelContainer/MarginContainer/TextureRect"
## Panel container.
@onready var _panel: PanelContainer = $"PanelContainer"
## Amount label.
@onready var _amount: Label = $"PanelContainer/MarginContainer/amount"
## Inventory data to show in cell. May be null.
var _object: InventoryData
## Check if slot is higlighted.
var _highlighted: bool
## Normal, basic position of [method get_ui_object].
var _ui_pos: Vector2 = Vector2.ZERO
## Are we currently following mouse?
var _drag_mode: bool = false

## Signal, that emitted, when this inventorySlot recieved a click
signal clicked(this: InventorySlot)
	
## Higlight a panel, showing that current slot is 'active'.
func set_highlight(higlighted: bool) -> void:
	_highlighted = higlighted
	if higlighted:
		var style_box := StyleBoxFlat.new()
		style_box.bg_color = Color(0.762, 0.762, 0.762, 1.0)
		_panel.add_theme_stylebox_override("panel", style_box)
	else:
		_panel.remove_theme_stylebox_override("panel")
	
## Replace object for panel. 
## 'object' may be null.
func set_inventory_data(data: InventoryData = null) -> void:
	if _object:
		_object.amount_changed.disconnect(_set_amount)
		
	_object = data
	if data:
		_object.amount_changed.connect(_set_amount)
		_set_amount(data.amount)
		_amount.show()
		_texture_rect.texture = data.object.slot_texture()
	else:
		_amount.hide()
		_texture_rect.texture = null

## Sets object.
## May be used as alternative to set_inventory_data.
func set_object(object: BasicObject, amount: int = 1) -> void:
	set_inventory_data(InventoryData.new(object, amount))

## Returns inventory data that currently in slot. May be null.
func get_inventory_data() -> InventoryData:
	return _object

## Return ui node, that contain only ui related nodes for object, and not panel.
func get_ui_object() -> Control:
	return _texture_rect

## Starts a dragging mode, in which object in slot will follow the mouse.
func set_drag_mode(enabled: bool) -> void: 	
	if enabled:
		assert(!_drag_mode, "Already in drag mode")
		_drag_mode = true
		_ui_pos = get_ui_object().position
	else:
		get_ui_object().position = _ui_pos
		_drag_mode = false

## Shows/hides text label
func set_amount_visibility(visible: bool) -> void:
	_amount.visible = visible

## Ui processing.
func _process(delta: float) -> void:
	if _drag_mode == true:
		get_ui_object().global_position = get_global_mouse_position()

## Sets amount ui label. 
func _set_amount(amount: int) -> void:
	_amount.text = "{0}".format([amount])
	

## Handle gui events.
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		clicked.emit(self)
