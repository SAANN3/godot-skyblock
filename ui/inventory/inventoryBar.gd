extends Control

## Ui inventory bar that player will see at the bottom.
class_name InventoryBar

## Ui slots.
@onready var slots: Array[InventorySlot] = []
## Position of current highlight.
var _highlighted_element: int = -1

## Init ui.
func _ready() -> void:
	for i: InventorySlot in $"slots".get_children():
		slots.append(i)

## Highlights slot at given position, while removing hihglight from previous slot.
func set_highlight(pos: int) -> void:
	if _highlighted_element != -1:
		slots[_highlighted_element].set_highlight(false)
	_highlighted_element = pos
	slots[pos].set_highlight(true)
 
## Sets objects for slot
func set_object(pos: int, object: BasicObject = null) -> void:
	slots[pos].set_object(object)
