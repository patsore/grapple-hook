extends BoneAttachment3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

@export var RAY_LENGTH = 1.5

@onready var marker =  $"../../LeftFootMarker"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var start_position = global_transform.origin
	var space_state = get_world_3d().direct_space_state

	var closest_point: Vector3 = Vector3.ZERO
	var closest_distance: float = RAY_LENGTH

	var directions = [
		Vector3(1, 0, 0),  # Right
		Vector3(-1, 0, 0), # Left
		Vector3(0, -1, 0), # Down
		Vector3(0, 0, 1),  # Forward
		Vector3(0, 0, -1)  # Backward
	]

	for direction in directions:
		var query = PhysicsRayQueryParameters3D.create(start_position,
			start_position + direction * RAY_LENGTH, 0x0000000F)
		var result = space_state.intersect_ray(query)

		if result:
			var distance = start_position.distance_to(result.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_point = result.position
	marker.global_transform.origin = closest_point
