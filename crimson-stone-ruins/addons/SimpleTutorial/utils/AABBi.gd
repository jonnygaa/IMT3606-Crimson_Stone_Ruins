class_name TutorialAABBi

# AABB class using integer Vector3 (Vector3i)

# Member variables
var position : Vector3i
var size : Vector3i
var end : Vector3i:
	set(v):
		if position.clamp(position, v.clamp(v, position)) < position:
			position = position.clamp(position, v.clamp(position, v))
		size = v - position
	get:
		return size + position

# Constructor
func _init(position : Vector3i = Vector3i(0, 0, 0), size : Vector3i = Vector3i(0, 0, 0)) -> void:
	self.position = position
	self.size = size

static func from_AABB_rounded(aabb : AABB) -> TutorialAABBi:
	return TutorialAABBi.new(round(aabb.position), round(aabb.size))

func to_AABB() -> AABB:
	return AABB(self.position, self.size)

# Method to check if a point is inside the AABB
func contains_point(point : Vector3i) -> bool:
	return (
		point.x >= position.x and point.x < position.x + size.x and
		point.y >= position.y and point.y < position.y + size.y and
		point.z >= position.z and point.z < position.z + size.z
	)

# Method to check if another AABB intersects with this one
func intersects(aabb : TutorialAABBi) -> bool:
	aabb = aabb.normalized()
	var my := self.normalized()
	# Find separating axis
	if aabb.position.x >= my.end.x or my.position.x >= aabb.end.x: return false
	if aabb.position.y >= my.end.y or my.position.y >= aabb.end.y: return false
	if aabb.position.z >= my.end.z or my.position.z >= aabb.end.z: return false
	return true

# Method to push this AABB inside another AABB (returns new TutorialAABBi)
func push_within(aabb : TutorialAABBi, ignore_y : bool) -> TutorialAABBi:
	aabb = aabb.normalized()
	var new_aabb = TutorialAABBi.new(self.position, self.size).normalized()
	new_aabb.position = new_aabb.position.clamp(aabb.position, aabb.end - new_aabb.size)
	if ignore_y:
		new_aabb.position.y = self.position.y
	return new_aabb

func expand_to_include(point : Vector3i) -> TutorialAABBi:
	var new_position : Vector3i = Vector3i(
		min(position.x, point.x),
		min(position.y, point.y),
		min(position.z, point.z)
	)
	var new_end_position : Vector3i = Vector3i(
		max(end.x, point.x + 1),
		max(end.y, point.y + 1),
		max(end.z, point.z + 1)
	)
	var new_size : Vector3i = new_end_position - new_position
	return TutorialAABBi.new(new_position, new_size)

# Method to check if two AABBs are equal
func equals(aabb : TutorialAABBi) -> bool:
	return position == aabb.position and size == aabb.size

# Method to check if this AABB encloses another AABB
func encloses(aabb : TutorialAABBi) -> bool:
	aabb = aabb.normalized()
	return (
		self.normalized().contains_point(aabb.position) and
		self.normalized().contains_point(aabb.end - Vector3i(1, 1, 1))
	)

# Method to normalize the AABB (ensures size is positive)
func normalized() -> TutorialAABBi:
	var new_position : Vector3i = position
	var new_size : Vector3i = size

	if size.x < 0:
		new_position.x += size.x
		new_size.x = -size.x
	if size.y < 0:
		new_position.y += size.y
		new_size.y = -size.y
	if size.z < 0:
		new_position.z += size.z
		new_size.z = -size.z

	return TutorialAABBi.new(new_position, new_size)

# Method to grow the AABB by a specified amount in all directions
func grow(amount : int) -> TutorialAABBi:
	var new_position : Vector3i = position - Vector3i(amount, amount, amount)
	var new_size : Vector3i = size + Vector3i(amount * 2, amount * 2, amount * 2)
	return TutorialAABBi.new(new_position, new_size)

# Method to grow the AABB by a specified amount in the x and z directions
func grow_xz(amount : int) -> TutorialAABBi:
	var new_position : Vector3i = position - Vector3i(amount, 0, amount)
	var new_size : Vector3i = size + Vector3i(amount * 2, 0, amount * 2)
	return TutorialAABBi.new(new_position, new_size)

func translated(pos : Vector3i) -> TutorialAABBi:
	return TutorialAABBi.new(self.position + pos, self.size)
