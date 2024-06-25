extends BoneAttachment3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

@export var RAY_LENGTH = 3.0

@onready var marker =  $"../../RightFootMarker"
@onready var root = $"../../.."
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var start_position = global_transform.origin
	var space_state = get_world_3d().direct_space_state

	var directions = [
		Vector3(0, -0.3, 0), # Down
		Vector3(1, 0, 0),  # Right
		Vector3(-1, 0, 0), # Left
		Vector3(0, 0, 1),  # Forward
		Vector3(0, 0, -1)  # Backward
	]

	for direction in directions:
		var query = PhysicsRayQueryParameters3D.create(start_position, start_position + direction * RAY_LENGTH, 0x0000000F)
		var result = space_state.intersect_ray(query)

		if !result.is_empty():
			var closest_point = result.position
			var distance = start_position.distance_to(result.position)

			marker.global_transform.origin = closest_point
			
			var quat_1 = Quaternion(Vector3.UP, PI)
			var quat_2 = Quaternion(Vector3.RIGHT, PI/2)
			
			var default_rotation = quat_2 * quat_1
			var normal: Vector3 = result.normal
			var angle = Vector3.UP.signed_angle_to(normal, root.global_transform.basis.z)
			var quat_3 = Quaternion(Vector3.FORWARD, angle)
			marker.basis = Basis(quat_3 * quat_2 * quat_1)
			break
