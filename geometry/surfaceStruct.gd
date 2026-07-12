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

## Creates an instance array out of surface struct.
func compile() -> ArrayMesh:
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	var arr_mesh := ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return arr_mesh
