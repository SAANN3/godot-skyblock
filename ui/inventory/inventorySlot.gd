extends Control
## Slot class for cell inventory system.
class_name InventorySlot

## Texture rect, which stores a texture.
@onready var _texture_rect: TextureRect = $"PanelContainer/MarginContainer/TextureRect"
## Panel container.
@onready var _panel: PanelContainer = $"PanelContainer"
## object to show in cell. May be null.
var _object: BasicObject
## Check if slot is higlighted.
var _highlighted: bool
## Normal, basic position of [method get_ui_object].
var _ui_pos: Vector2 = Vector2.ZERO
## Are we currently following mouse?
var _drag_mode: bool = false
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
func set_object(object: BasicObject = null) -> void:
	_object = object
	if object:
		_texture_rect.texture = object.slot_texture()
	else:
		_texture_rect.texture = null

## Returns object that currently in slot. May be null.
func get_object() -> BasicObject:
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

## Ui processing.
func _process(delta: float) -> void:
	if _drag_mode == true:
		get_ui_object().global_position = get_global_mouse_position()


	
