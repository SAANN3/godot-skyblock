extends RefCounted
class_name SurfaceStruct

var verts: PackedVector3Array
var uvs: PackedVector2Array
var normals: PackedVector3Array
func _init(verts: PackedVector3Array, uvs: PackedVector2Array, normals: PackedVector3Array) -> void:
	self.verts = verts
	self.uvs = uvs
	self.normals = normals

func append(struct: SurfaceStruct) -> void:
	self.verts.append_array(struct.verts)
	self.uvs.append_array(struct.uvs)
	self.normals.append_array(struct.normals)
	
