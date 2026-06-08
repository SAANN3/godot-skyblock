extends RefCounted
# Basic point for drawing triangles with another points
class_name PlanePoint

enum PointRadiusDirection {
	Inside,
	Outside
}

var point: Vector3
var roundness: float = 0
var curve_segments: float = 32
var roundness_direction: PointRadiusDirection = PointRadiusDirection.Outside

func _init(point: Vector3) -> void:
	self.point = point

func set_radius(roundness: float, radius_direction: PointRadiusDirection = PointRadiusDirection.Outside) -> void:
	self.roundness = roundness
	self.roundness_direction = radius_direction

func find_perpindicular(with: Vector3, another_point: Vector3) -> Vector3:
	return (with - another_point).cross(point - another_point).normalized()



func create_corner(next_point: PlanePoint, previous_point: PlanePoint, intersection: Vector3) -> PackedVector3Array:
	if self.roundness != 0:
		return self.create_round_corner(next_point, previous_point, intersection)
	else:
		return self.create_square_corner(next_point, previous_point, intersection)
		

func create_square_corner(next_point: PlanePoint, previous_point: PlanePoint, intersection: Vector3) -> PackedVector3Array:
	var verts: PackedVector3Array = PackedVector3Array()
	var next_line_center_real: Vector3 = next_point.point + (point - next_point.point) * 0.5
	var previous_line_center_real: Vector3 = previous_point.point + (point - previous_point.point) * 0.5
	verts.append_array([
		intersection,
		next_line_center_real,
		self.point,
	])
	verts.append_array([
		intersection,
		self.point,
		previous_line_center_real,
	])
	return verts
	
func create_round_corner(next_point: PlanePoint, previous_point: PlanePoint, intersection: Vector3) -> PackedVector3Array:
	var next_line_center: Vector3 = next_point.point + (point - next_point.point) * (1 - (roundness / 2))
	var previous_line_center: Vector3 = previous_point.point + (point - previous_point.point) * (1 - (roundness / 2))
	
	var next_line_center_real: Vector3 = next_point.point + (point - next_point.point) * 0.5
	var previous_line_center_real: Vector3 = previous_point.point + (point - previous_point.point) * 0.5
	var next_center_diff: Vector3 = next_line_center - intersection
	var previous_center_diff: Vector3 = previous_line_center - intersection
	var angle: float = next_center_diff.angle_to(previous_center_diff)
	var radius_diff: float = previous_center_diff.length() / next_center_diff.length()
	
	var verts: PackedVector3Array = PackedVector3Array()
	verts.append_array(
		create_circle(
			next_line_center,
			intersection,
			-rad_to_deg(angle),
			radius_diff,
			false,
			find_perpindicular(previous_line_center, next_line_center)
		)
	)
	if roundness < 1 && roundness > 0:
		verts.append_array([
			intersection,
			verts[verts.size() - 1],
			previous_line_center_real,
		])
		verts.append_array([
			intersection,
			next_line_center_real,
			next_line_center,
		])
	return verts

func create_circle(
	start: Vector3, 
	circle_center: Vector3,
	angle: float,
	other_radius_scale: float = 1,
	other_axis_90_deg: bool = false,
	_perpendicular: Vector3 = Vector3.ZERO
) -> PackedVector3Array:
	var perpendicular: Vector3 = Vector3.ZERO
	if _perpendicular.is_zero_approx():
		perpendicular = find_perpindicular(circle_center, start)
	else:
		perpendicular = _perpendicular
	var perpindicular_axis : Vector3 = Helper.rotate_around(
		start,
		circle_center,
		find_perpindicular(circle_center, start),
		deg_to_rad(90 as float if other_axis_90_deg else angle )
	)
	perpindicular_axis = (perpindicular_axis - circle_center) * other_radius_scale + circle_center
	var previous_point: Vector3 = start
	var verts: PackedVector3Array = PackedVector3Array()
	for i in range(0, curve_segments + 1):
		var k := i / curve_segments
		var new_point := Helper.rotate_around(
			start,
			circle_center,
			perpendicular,
			deg_to_rad(angle * k)
		)
		var second_point := Helper.rotate_around(
			((start - circle_center) * other_radius_scale + circle_center),
			circle_center,
			perpendicular,
			deg_to_rad(angle * k)
		)
		var intersection_point := Helper.intersection(
			new_point,
			(perpindicular_axis - circle_center) + new_point,
			second_point,
			(start - circle_center) + second_point,
		)
		new_point = intersection_point
		verts.append(circle_center)
		verts.append(new_point if angle > 0 else previous_point)
		verts.append(previous_point if angle > 0 else new_point)
		previous_point = new_point
	return verts

func create_triangle(with: Vector3, with_2: Vector3) -> PackedVector3Array:
	return PackedVector3Array([
		with,
		with_2,
		point,
	])
