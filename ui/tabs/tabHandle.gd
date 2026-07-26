extends Control

## Handle for tab which will be displayed in row in inventory.
class_name TabHandle

## Tab icon. 
@onready var _icon: TextureRect = $"MarginContainer/handleIcon" 

## Highlighted back panel, showing that tab is selected.
@onready var _highlight: PanelContainer = $"HighlightPanel"

## Triggered when handle was clicked.
signal clicked()

## Sets current icon.
func set_icon(texture: Texture2D) -> void:
	_icon.texture = texture
	
## Highlights current handle.
func set_higlighted(highlighted: bool) -> void:
	_highlight.visible = highlighted


## Handles ui input.
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		clicked.emit()
