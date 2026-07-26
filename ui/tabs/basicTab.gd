extends Control

## A basic tab which defines a contract for tab ui.
class_name BasicTab

## A texture, that will be used as tab icon.
@export var _icon: Texture2D 

## Name of tab, which will be displayed upon hovering or opening.
@export var _name: String

## A hint for ui, which suggest giving max space to this node
@export var _fullscreen: bool = false

## Hides or shows ui tab.
func set_visibility(visible: bool) -> void:
	if visible:
		show()
	else:
		hide()

## Returns a icon for given tab.
## Should return the same node for given instance.
func get_icon() -> Texture2D:
	return _icon
	

## Returns a main ui of the tab.
## Should return the same node for given instance.
func get_ui() -> Control:
	return self

## Returns text which should represent a name for this tab, which will be displayed to user.
func get_tab_name() -> String:
	return _name
