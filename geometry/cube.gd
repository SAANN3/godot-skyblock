extends RefCounted
## Handles cube geometry verts.
class_name CubeHelper


## Upper plane of a cube.
var _up: PlaneHelper
## Down side of a cube.
var _down: PlaneHelper
## Left side of a cube.
var _left: PlaneHelper
## Right side of a cube.
var _right: PlaneHelper
## Front side of a cube.
var _front: PlaneHelper
## Back side of a cube.
var _back: PlaneHelper
## Default constructor, shouldn't be used.
func _init() -> void:
	pass

## Constructor for a default cube with size of 1x1 and center at [code]Vector(0, 0, 0)[/code].
## All cubes sides will be placed within [code]Vector(0, 0, 0) to Vector(1, 1, 1) [/code] range.
## The difference from [method new_centered] is that cube not uses floats during initialization.
static func new_from_corner() -> CubeHelper:
	var _self := CubeHelper.new()
	_self._up = PlaneHelper.new(Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0))
	_self._down = PlaneHelper.new(Vector3(0, 0, 1), Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1))
	_self._left = PlaneHelper.new(Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0))
	_self._right = PlaneHelper.new(Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1))
	_self._front = PlaneHelper.new(Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1))
	_self._back = PlaneHelper.new(Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0))
	return _self

# I guess its broken, when scaling. So uncomenting for later.
## Constructor for a default cube with size of 1x1 and center at [code]Vector(0, 0, 0)[/code].
## So each side will be offseted for 0.5 from center.
## The difference from [method new_from_corner] is that cube uses floats, and positioned around center point.
#static func new_centered() -> CubeHelper:
	#var _self := CubeHelper.new()
	#_self._up = PlaneHelper.new(Vector3(-0.5, 0.5, -0.5), Vector3(-0.5, 0.5, 0.5), Vector3(0.5, 0.5, 0.5), Vector3(0.5, 0.5, -0.5))
	#_self._down = PlaneHelper.new(Vector3(-0.5, -0.5, 0.5), Vector3(-0.5, -0.5, -0.5), Vector3(0.5, -0.5, -0.5), Vector3(0.5, -0.5, 0.5))
	#_self._left = PlaneHelper.new(Vector3(-0.5, -0.5, -0.5), Vector3(-0.5, -0.5, 0.5), Vector3(-0.5, 0.5, 0.5), Vector3(-0.5, 0.5, -0.5))
	#_self._right = PlaneHelper.new(Vector3(0.5, -0.5, 0.5), Vector3(0.5, -0.5, -0.5), Vector3(0.5, 0.5, -0.5), Vector3(0.5, 0.5, 0.5))
	#_self._front = PlaneHelper.new(Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5), Vector3(0.5, 0.5, 0.5), Vector3(-0.5, 0.5, 0.5))
	#_self._back = PlaneHelper.new(Vector3(0.5, -0.5, -0.5), Vector3(-0.5, -0.5, -0.5), Vector3(-0.5, 0.5, -0.5), Vector3(0.5, 0.5, -0.5))
	#return _self

## Scales cube for given proportions, using as anchor a bottom corner point.
## Default value means do nothing, as change scale is 1.
func scale(proportions: Vector3 = Vector3(1, 1, 1)) -> void:
	for i: PlaneHelper in to_array():
		i.scale(proportions)

## Translates (moves) current cube to given position.
func translate(pos: Vector3) -> void:
	for i: PlaneHelper in to_array():
		i.translate(pos)
		
## 'Compiles' cube.
func to_surface_struct() -> SurfaceStruct:
	var out: SurfaceStruct = null
	for i: PlaneHelper in [_up, _down, _left, _right, _front, _back]:
		if i == null:
			continue
		if out == null:
			out = i.to_surface_struct_primitive()
		else:
			out.append(i.to_surface_struct_primitive())
	return out

# this will ignore any future rotation.
# Probably unoptimized...
## Tests, if this cube will intersect with other.
func intersects_with_cube(cube: CubeHelper) -> bool:
	# Check, if cube may be go through another cube, altough its points didn't touch.
	# As example cube is taller than another, but it touches the cube, like piercing it.
	if !(
		(_up.bl.point.y <= cube._up.bl.point.y && _up.bl.point.y <= cube._down.bl.point.y) ||
		(_down.bl.point.y >= cube._up.bl.point.y && _down.bl.point.y >= cube._down.bl.point.y)
	):
		if !(
			(_right.bl.point.x <= cube._right.bl.point.x && _right.bl.point.x <= cube._left.bl.point.x) ||
		 	(_left.bl.point.x >= cube._right.bl.point.x && _left.bl.point.x >= cube._left.bl.point.x)
		):
			if !(
				(_front.bl.point.z <= cube._front.bl.point.z && _front.bl.point.z <= cube._back.bl.point.z) ||
				(_back.bl.point.z >= cube._front.bl.point.z && _back.bl.point.z >= cube._back.bl.point.z)
			):
				return true
	return false
	
	

# this will ignore any future rotation.
## Tests, if a given point will be inside cube.
func intersects_with_point(point: Vector3) -> bool:
	var intersections: int = 0
	if _up.bl.point.y >= point.y && _down.bl.point.y <= point.y:
		intersections += 1
	if _right.bl.point.x >= point.x && _left.bl.point.x <= point.x:
		intersections += 1
	if _front.bl.point.z >= point.z && _back.bl.point.z <= point.z:
		intersections += 1
		
	return intersections == 3


## Returns iterator for all sides of cube.
func to_array() -> Array[PlaneHelper]:
	return [
		_up,
		_down,
		_back,
		_left,
		_front,
		_right
	]
