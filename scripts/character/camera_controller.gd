class_name CameraController
extends Node3D

# Public Camera references for Godot (linked in the editor)

# Sensitivity and field of view variables
@export var sens_x = 1.0
@export var sens_y = 1.0
var base_fov = 90.0
var max_fov = 140.0
var wall_run_tilt = 15.0

# Internal state variables
var wish_tilt = 0.0
var cur_tilt = 0.0
var current_look = Vector2()
var sway = Vector2()
var rb : CharacterBody3D

var main_camera: Camera3D
var weapon_camera: Camera3D 

var fov: float
var rotation_quat = Quaternion()

@onready var camera_pos: BoneAttachment3D = $"../WeaponsScene/Node/Skeleton3D/NeckBone"

func _ready():
	main_camera = get_node("MainCamera")
	#main_camera.get_viewport().debug_draw = Viewport.DEBUG_DRAW_NORMAL_BUFFER
	rb = get_parent_node_3d()
	cur_tilt = rotation_quat.get_euler().z
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	main_camera.global_transform.origin = camera_pos.global_transform.origin + 20 * camera_pos.global_transform.basis.z
	var added_fov = rb.velocity.length() - 3.44
	fov = lerp(fov, base_fov + added_fov, 0.5)
	fov = clamp(fov, base_fov, max_fov)
	main_camera.fov = fov

	current_look = current_look.lerp(current_look + sway, 0.8)
	cur_tilt = lerp_angle(cur_tilt, wish_tilt, 0.1)
	var rotation_quat_tilt = Quaternion(Vector3.FORWARD, cur_tilt)

	sway = sway.lerp(Vector2.ZERO, 0.2)
	rotation_quat = Quaternion(Vector3.RIGHT, -current_look.y)
	transform.basis = Basis(rotation_quat * rotation_quat_tilt)


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_input = event.relative
		mouse_input.x *= -sens_x
		mouse_input.y *= sens_y

		current_look.x += mouse_input.x
		current_look.y = clamp(current_look.y + mouse_input.y, -1.5708, 1.5708)

		rotation_quat = Quaternion(Vector3.RIGHT, -current_look.y)
		transform.basis = Basis(rotation_quat)
		get_parent().transform.basis = Basis(Quaternion(Vector3.UP, current_look.x))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#if Input.is_action_pressed("move_crouch") && rb.is_on_floor():
		#main_camera.transform.origin = lerp(main_camera.transform.origin, Vector3(0, -0.5, 0), 0.25)
	#else:
		#main_camera.transform.origin = lerp(main_camera.transform.origin, Vector3.ZERO, 0.25)

func punch(dir: Vector2):
	sway += dir

# Setter functions
func set_tilt(new_val):
	wish_tilt = new_val

func set_x_sens(new_val):
	sens_x = new_val

func set_y_sens(new_val):
	sens_y = new_val
