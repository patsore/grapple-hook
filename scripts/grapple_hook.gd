extends Node3D

@export var hook_speed: float = 15.0
@export var retract_speed: float = 10.0
@export var max_distance: float = 1000.0
@export var hook_node: String = "Hook"

var is_hooked: bool = false
var hook_target: Vector3
#var hook_instance: Node3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func shoot_hook(start_pos: Vector3, direction: Vector3):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_pos, (start_pos + direction) * max_distance, 0x0000000F)
	var result = space_state.intersect_ray(query)
	
	if result:
		hook_target = result.position
		is_hooked = true
		#hook_instance = preload("res://path_to_your_hook_scene.tscn").instantiate()
		#get_node(hook_node).add_child(hook_instance)
		#hook_instance.global_transform.origin = start_pos

func retract_hook(player: CharacterBody3D):
	var direction = (hook_target - player.global_transform.origin).normalized()
	player.velocity += (direction * retract_speed * get_process_delta_time())
	print((direction * retract_speed * get_process_delta_time()))
	if player.global_transform.origin.distance_to(hook_target) < 1.0:
		is_hooked = false
		#hook_instance.queue_free()

func _process(delta):
	if is_hooked:
		retract_hook($"../..")

func _input(event):
	if Input.is_action_pressed("grapple"):
		var camera =  $"../MainCamera" as Camera3D
		var from = camera.global_transform.origin
		var to = from + camera.global_transform.basis.z * max_distance
		shoot_hook(from, to)
	else:
		is_hooked = false
