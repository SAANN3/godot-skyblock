extends RefCounted
## A class for loading and storing data, related to objects.
class_name ResourceSystem

## Mapped data for all data.
## Mapped as id - obj.
var _data: Dictionary[String, BasicResource]
## Constructor.
func _init() -> void:
	_load_resources()

## Loads all resources from storage folder.
func _load_resources() -> void:
	const dir := "res://storage/objects"
	var items := DirAccess.get_files_at(dir)
	for i in items:
		var resource: BasicResource = load("{0}/{1}".format([dir, i]))
		# validate resources
		assert(!_data.has(resource.id), "Already having ID={0}, possibly a duplicate.".format([resource.id]))
		_data[resource.id] = resource

## Returns all resources.
func get_resources() -> Dictionary[String, BasicResource]:
	return _data.duplicate()

## Returns a resources for given id.
## This function assumes, that given id exists inside map, resulting a crash otherwise.
func get_resource(id: String) -> BasicResource:
	return _data[id]

## Returns only array of object ids.
func get_ids() -> Array[String]:
	return _data.keys()

## Returns all objects, initialized from resources.
func get_objects() -> Dictionary[String, BasicObject]:
	var out: Dictionary[String, BasicObject] = {}
	for i: String in _data:
		pass
	return out
	
## Returns an object for given id.
## This function assumes, that given id exists inside map, resulting a crash otherwise.
func get_object(id: String) -> BasicObject:
	var res: BasicResource = _data[id]
	match res.type:
		BasicResource.Types.Block:
			var typed: BlockResource = res
			return BlockObject.new(typed.id, typed.texture)
	
	assert(false, "Unknown object type {0}".format([res.type]))
	return null	
	
