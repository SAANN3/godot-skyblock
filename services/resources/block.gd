extends BasicResource
## Container for storing information about Block.
class_name BlockResource

## A single texture, which will be used for anything, related to this block.
@export var texture: Texture2D = null
## Can this block be dropped when breaked? Default is true.
@export var droppable: bool = true
## Override parent data.
func _init() -> void:
	super(Types.Block)

	
