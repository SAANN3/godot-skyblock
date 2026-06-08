extends RefCounted
class_name Helper

static func flatten2DVector3(arr: Array[Array]) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for i in arr:
		for x: Variant in i:
			out.append(x)
	return out

static func rotate_around(point: Vector3, around: Vector3, axis: Vector3, angle: float) -> Vector3:
	var inverted_axis: Vector3 = Vector3(1, 1, 1)
	return (((point - around) * inverted_axis).rotated(axis, angle)) + around
	
static func scale_around(point: Vector3, around: Vector3, scale: float, direction: Vector3) -> Vector3:
	return around + ((point - around) * direction * scale)

static func intersection(point_1: Vector3, point_2: Vector3, spoint_1: Vector3, spoint_2: Vector3) -> Vector3:
	var v1: Vector3 = point_2 - point_1
	var v2: Vector3 = spoint_2 - spoint_1
	var cross: Vector3 = v1.cross(v2)
	var up: float = (spoint_1 - point_1).cross(v2).dot(cross)
	var down: float = cross.dot(cross)
	var t: float = up / down
	
	return point_1 + (t * v1)
	
static func generate_normals(vertices: PackedVector3Array) -> PackedVector3Array:
	var verts: PackedVector3Array = PackedVector3Array()
	for i in range(0, len(vertices), 3):
		var first: Vector3 = vertices[i]
		var second: Vector3 = vertices[i + 1]
		var third: Vector3 = vertices[i + 2]
		
		var line_1: Vector3 = first - second
		var line_2: Vector3 = second - third
		verts.append(-line_1.cross(line_2).normalized())
		verts.append(-line_1.cross(line_2).normalized())
		verts.append(-line_1.cross(line_2).normalized())
		
	return verts
