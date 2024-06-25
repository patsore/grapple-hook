class_name GrapplingHook
extends Node3D

signal hook_attached(point_of_contact: Vector3)
signal hook_detached
signal hook_shot(direction: Vector3)

var hook_target: Vector3
var is_attached: bool
var shifted_positions: bool

@onready var head = $"../Head"
@onready var parent: CharacterBody3D = $".."

@export var hook_speed = 25.0
@export var retract_speed = 10.0
@export var max_distance = 100
@export var initial_push_strength = 10.0

@export var line_segments = 10

@onready var hook_instance = MeshInstance3D.new()
@onready var zip_mesh: CylinderMesh = load("res://resources/zipline/zipline_mesh.tres")
# New nodes for the zipline
var path: Path3D = Path3D.new()
var mesh_instance: MultiMeshInstance3D = MultiMeshInstance3D.new()

func _ready():
	hook_instance.mesh = SphereMesh.new()
	hook_instance.name = "GrapplingHook"
	hook_instance.top_level = true
	add_child(hook_instance)
	hook_instance.visible = false
	
	# Setup for the zipline
	add_child(path)
	path.name = "ZiplinePath"
	
	mesh_instance.multimesh = MultiMesh.new()
	mesh_instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh_instance.multimesh.instance_count = line_segments
	mesh_instance.multimesh.mesh = zip_mesh
	
	add_child(mesh_instance)
	set_physics_process(false)
	mesh_instance.visible = false

@onready var hand: BoneAttachment3D = $"../WeaponsScene/Node/Skeleton3D/LeftHand"

# Update the zipline visuals
func update_zipline():
	var start_position = to_local(hand.global_transform.origin)
	var end_position = to_local(hook_instance.global_transform.origin)
	
	var curve = Curve3D.new()
	curve.add_point(start_position)
	curve.add_point(end_position)
	path.curve = curve
	
	var distance = start_position.distance_to(end_position)
	var segment_length = distance / line_segments
	zip_mesh.height = segment_length

	for i in range(line_segments):
		var t = segment_length * i + segment_length / 2
		var position = curve.sample_baked(t)
		var point_transform = Transform3D()
		point_transform.origin = position
		
		if i <= line_segments - 1:
			var next_position = curve.sample_baked(float(i + 1) / float(line_segments))
			var direction = (next_position - position).normalized()
			point_transform.basis = Basis(Vector3.RIGHT, direction, Vector3.UP)
		
		mesh_instance.multimesh.set_instance_transform(i, point_transform)

func shoot_grappling_hook():
	hook_instance.global_transform.origin = head.global_transform.origin
	var direction = -head.global_transform.basis.z
	hook_instance.global_transform.origin += direction * 2.0
	
	hook_instance.visible = true
	mesh_instance.visible = true
	hook_target = direction
	is_attached = false
	set_physics_process(true)
	hook_shot.emit(direction)

func _physics_process(delta):
	if hook_instance.visible and not is_attached:
		hook_instance.translate(hook_target * hook_speed * delta)
		update_zipline()
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(hook_instance.global_transform.origin, hook_instance.global_transform.origin + hook_target * hook_speed * delta, 0x0000000F)
		var result = space_state.intersect_ray(query)
		if result:
			hook_instance.global_transform.origin = result.position
			hook_attached.emit(result.position)
	elif is_attached:
		retract_grappling_hook()
		update_zipline()

func retract_grappling_hook():
	var from = head.global_transform.origin
	var to = hook_target
	
	var space_state = parent.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, 0x0000000F)
	var result = space_state.intersect_ray(query)
	
	if result and (result.position - hook_target).length() > 1.0:
		if shifted_positions:
			print("disconnected here")
			hook_detached.emit()
		else:
			shifted_positions = true
			hook_target = result.position
	else:
		var direction_to_hook = (hook_target - head.global_transform.origin).normalized()
		var player_view_direction = -head.global_transform.basis.z.normalized()
		var angle = direction_to_hook.angle_to(player_view_direction)
		if angle >= deg_to_rad(90.0):
			hook_detached.emit()
		
		parent.velocity += direction_to_hook * retract_speed * get_physics_process_delta_time()

func _on_hook_attached(point_of_contact: Vector3) -> void:
	hook_target = point_of_contact
	is_attached = true
	shifted_positions = false
	
	var push_direction = (point_of_contact - global_transform.origin).normalized()
	parent.velocity += push_direction * initial_push_strength * Vector3(1, 0.75, 1)
	mesh_instance.visible = true
	update_zipline()

func _on_hook_detached() -> void:
	is_attached = false
	hook_instance.visible = false
	mesh_instance.visible = false
	set_physics_process(false)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("move_crouch"):
		hook_detached.emit()
	if Input.is_action_just_pressed("grapple"):
		shoot_grappling_hook()
