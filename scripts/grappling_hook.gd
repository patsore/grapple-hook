class_name GrapplingHook
extends Node3D

signal hook_attached(point_of_contact: Vector3)

signal hook_detached

var hook_target: Vector3
var is_attached: bool
var shifted_positions: bool

@onready var head = $"../Head"
@onready var parent: CharacterBody3D = $".."

@export var hook_speed = 25.0
@export var retract_speed = 10.0

@export var max_distance = 100

@export var initial_push_strength = 10.0

@onready var hook_instance = MeshInstance3D.new()

func _ready():
	hook_instance.mesh = SphereMesh.new()
	hook_instance.name = "GrapplingHook"
	hook_instance.top_level = true
	add_child(hook_instance)
	hook_instance.visible = false

#Throws a grappling hook
#that will attach to the first solid object it hits 
#and pull you towards it.
func shoot_grappling_hook():
	# Define initial hook position and direction
	hook_instance.global_transform.origin = head.global_transform.origin
	var direction = -head.global_transform.basis.z
	hook_instance.global_transform.origin += direction * 2.0  # Slightly offset in front of the character
	
	# Make the hook visible and start moving it
	hook_instance.visible = true
	hook_target = direction
	is_attached = false
	# Move the hook forward in the specified direction
	set_physics_process(true)

func _physics_process(delta):
	if hook_instance.visible and not is_attached:
		hook_instance.translate(hook_target * hook_speed * delta)
		# Check for collision
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(hook_instance.global_transform.origin, hook_instance.global_transform.origin + hook_target * hook_speed * delta, 0x0000000F)
		var result = space_state.intersect_ray(query)
		if result:
			hook_instance.global_transform.origin = result.position
			hook_attached.emit(result.position)
	elif is_attached:
		retract_grappling_hook()

func retract_grappling_hook():
	var from = head.global_transform.origin
	var to = hook_target
	
	var space_state = parent.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, 0x0000000F)
	var result = space_state.intersect_ray(query)
	
	if result && (result.position - hook_target).length() > 1.0:
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


#When your hook connects to a surface, you will get a slight push forward towards the direction you are aiming.
#Jumping just after the grappling hook reaches a surface will grant you a bit of extra momentum.
func _on_hook_attached(point_of_contact: Vector3) -> void:
	hook_target = point_of_contact
	is_attached = true
	shifted_positions = false
	
	var push_direction = (point_of_contact - global_transform.origin).normalized()
	parent.velocity += push_direction * initial_push_strength * Vector3(1, 0.75, 1)

func _on_hook_detached() -> void:
	is_attached = false
	hook_instance.visible = false
	set_physics_process(false)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("move_crouch"):
		hook_detached.emit()
	if Input.is_action_just_pressed("grapple"):
		shoot_grappling_hook()
