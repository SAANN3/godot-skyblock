extends Resource
## Basic container for storing minimal required data for casting to more concrete resources.
class_name BasicResource
## Possible types of resource.
enum Types {
	Block
}
## Current type of resource.
var type: Types
## Obejct id name.
@export var id: String = ""
## Constructor.
func _init(type: Types) -> void:
	self.type = type
