extends BasicResource
## Container for storing information about Block.
class_name BlockResource

## A single texture, which will be used for anything, related to this block.
@export var texture: Texture2D = null
## Override parent data
func _init() -> void:
	super(Types.Block)
