extends RefCounted
class_name PlaneHelper

var bl: PlanePoint
var br: PlanePoint
var tl: PlanePoint
var tr: PlanePoint

var bottom_left: Vector3:
	get:
		return bl.point
	set(value):
		bl.point = value
var bottom_right: Vector3:
	get:
		return br.point
	set(value):
		br.point = value
var top_left: Vector3:
	get:
		return tl.point
	set(value):
		tl.point = value
var top_right: Vector3:
	get:
		return tr.point
	set(value):
		tr.point = value

func _init(br: Vector3, bl: Vector3, tl: Vector3, tr: Vector3) -> void:
	self.bl = PlanePoint.new(bl)
	self.br = PlanePoint.new(br)
	self.tl = PlanePoint.new(tl)
	self.tr = PlanePoint.new(tr)
	
func resize(br: Vector3, bl: Vector3, tl: Vector3, tr: Vector3) -> void:
	self.bl.point = bl
	self.br.point = br
	self.tl.point = tl
	self.tr.point = tr
	
func resize_relative(
	bl: Vector3 = Vector3.ZERO,
	br: Vector3 = Vector3.ZERO,
	tl: Vector3 = Vector3.ZERO,
	tr: Vector3 = Vector3.ZERO
) -> void:
	self.bl.point += bl
	self.br.point += br
	self.tl.point += tl
	self.tr.point += tr

## Translates (moves) current plane to given position.
func translate(pos: Vector3) -> void:
	for i: PlanePoint in to_array():
		i.point += pos


func scale(proportions: Vector3) -> void:
	var points := to_array()
	for i in range(len(points)):
		points[i].point = points[i].point * proportions 
	
func find_center() -> Vector3:
	var sum := Vector3.ZERO
	var arr := to_array()
	for i in arr:
		sum += i.point
	return sum / len(arr)
	
func to_vertices() -> PackedVector3Array:
	var center := find_center()
	var verts: PackedVector3Array = PackedVector3Array()
	for i: PackedVector3Array in [
		self.tl.create_corner(tr, bl, center),
		self.tr.create_corner(br, tl, center),
		self.br.create_corner(bl, tr, center),
		self.bl.create_corner(tl, br, center),
	]:
		verts.append_array(i)
	return verts

# Probably broken, need better way
func to_uv(vertices: PackedVector3Array) -> PackedVector2Array:
	var uvs: PackedVector2Array = PackedVector2Array()
	var center: Vector3 = find_center()
	for i in vertices:
		var dir: Vector3 = center - i
		var y: float = dir.x
		var x: float = dir.z
		if dir.y:
			if dir.z != 0:
				y = dir.y
				x = dir.z
			else:
				y = dir.x
				x = dir.y
			
		uvs.append(Vector2(x, y))
	return uvs
	
func to_normals(vertices: PackedVector3Array) -> PackedVector3Array:
	return Helper.generate_normals(vertices)
	
func to_surface_struct() -> SurfaceStruct:
	var verts: PackedVector3Array = self.to_vertices()
	return SurfaceStruct.new(
		verts,
		self.to_uv(verts),
		self.to_normals(verts)
	)
	
## Returns primitive surface struct, containing only two triangles.
func to_surface_struct_primitive() -> SurfaceStruct: 
	var verts: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	verts.append_array(tr.create_triangle(tl.point, br.point))
	verts.append_array(bl.create_triangle(br.point, tl.point))
	uvs.append_array(PackedVector2Array([
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(0, 0),
	]))
	uvs.append_array(PackedVector2Array([
		Vector2(0, 1),
		Vector2(1, 0),
		Vector2(1, 1),
	]))
	
	return SurfaceStruct.new(
		verts,
		uvs,
		self.to_normals(verts)
	)
	
func to_array() -> Array[PlanePoint]:
	return [self.bl, self.br, self.tl, self.tr]

func from_array(points: Array[PlanePoint]) -> void:
	self.bl = points[0]
	self.br = points[1]
	self.tl = points[2]
	self.tr = points[3]
