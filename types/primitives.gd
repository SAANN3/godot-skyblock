extends RefCounted
## Helper for making some interaction with primitives
class_name Primitives

## Checks if float is approximately an int.
static func is_int(f: float) -> bool:
	return is_equal_approx(f, roundf(f))
