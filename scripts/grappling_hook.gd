class_name GrapplingHook
extends Node

#modifiers
@export var hook_speed: float = 15.0
@export var retract_speed: float = 10.0
@export var max_distance: float = 1000.0
#state
var is_hooked = false
var hook_target: Vector3

@onready var parent = $".."

@onready var head = $"../Head"
func shoot_hook():
	var from = head.global_transform.origin
	var to = from + -head.global_transform.basis.z * max_distance
	var space_state = parent.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, 0x0000000F)
	var result = space_state.intersect_ray(query)
	
	if result:
		hook_target = result.position
		var debug_sphere = CSGSphere3D.new()
		debug_sphere.radius = 0.1
		debug_sphere.transform.origin = hook_target
		var material = load("res://addons/kenney_prototype_tools/materials/light/material_01.tres")
		debug_sphere.material = material
		get_tree().root.add_child(debug_sphere)
		is_hooked = true

func retract_hook():
	var direction = (hook_target - parent.global_transform.origin)
	if parent.global_transform.origin.distance_to(hook_target) < 1.0:
		is_hooked = false
	parent.velocity += direction.normalized() * hook_speed * get_physics_process_delta_time()
