extends CharacterBody3D

var default_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = default_gravity

# Ground
var walk_speed := 4.0
var run_speed := 6.0
var gr_accel := 20.0

# Air
var air_speed := 3.0
var air_accel := 20.0
var max_air_velocity := 20.0

# Jump
var jump_up_speed := 4.2
var dash_speed := 6.0

# Wall
var wall_speed := 10.0
var wall_climb_speed := 4.0
var wall_accel := 20.0
var wall_run_time := 3.0
var wall_stickiness := 20.0
var wall_stick_distance := 1.0
var wall_floor_barrier := 40.0
var wall_ban_time := 4.0
var banned_ground_normal := Vector3.ZERO
var wall_jump_power := 10.0

# Cooldowns
var can_jump := true
var can_d_jump := true
var wall_ban := 0.0
var wr_timer := 0.0
var wall_stick_timer := 0.0

# States
var running := false
var jump := false
var crouched := false
var grounded := false

var ground: Shape3D

var ground_normal := Vector3.UP

# Grappling Hook
var is_hooked: bool = false
var hook_target: Vector3
var hook_instance: Node3D
@export var hook_speed: float = 15.0
@export var retract_speed: float = 10.0
@export var max_distance: float = 1000.0
@export var hook_node: String = "Hook"

enum State {
	WALKING,
	FLYING,
	WALLRUNNING
}

@onready var camera_controller: CameraController = $Head 
@onready var left_cast = $LeftCast
@onready var right_cast = $RightCast

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	var state = _compute_state()
	
	# Map inputs to character space
	var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	
	# Map character space to world space
	var wish_dir = Vector3(input_vec.x, 0, input_vec.y) * transform.basis.inverse()
	match state:
		State.WALKING: 
			camera_controller.set_tilt(0)
			_walk(wish_dir, run_speed if running else walk_speed, gr_accel)
		State.FLYING:
			camera_controller.set_tilt(0)
			velocity.y -= gravity * delta
			_air_move(delta, wish_dir, air_speed, air_accel)
		State.WALLRUNNING:
			_wall_movement(delta, wish_dir, wall_speed, wall_accel)
	
	if Input.is_action_just_pressed("move_jump"):
		match state:
			State.WALKING: 
				_jump()
			State.FLYING:
				_doublejump(wish_dir) 
			State.WALLRUNNING:
				_walljump()
				
	var curve: Curve3D = hook_line.curve
	hook_line.global_transform.origin = global_transform.origin
	var norm_vel = -velocity.normalized() / 8
	var old_norm_vel = curve.get_point_out(0)
	curve.set_point_out(0, lerp(old_norm_vel, norm_vel, 0.25))
	

	if is_hooked:
		_retract_hook()
	else:
		curve.set_point_out(0, Vector3.ZERO)
		gravity = default_gravity
		curve.set_point_position(1, Vector3(0.01, 0, 0))
	
	move_and_slide()

func _compute_state() -> State:
	running = Input.is_action_pressed("move_sprint")
	
	if is_on_floor():
		return State.WALKING
	elif is_on_wall_only():
		return State.WALLRUNNING
	else:
		return State.FLYING

func _air_move(delta, wish_dir, max_speed, acceleration):
	var projVel = Vector3(velocity.x, 0, velocity.z).dot(wish_dir)
	var accelVel = acceleration * delta
	
	if projVel + accelVel > max_speed:
		accelVel = max(0, max_speed - projVel)
	velocity += wish_dir.normalized() * accelVel

func _wall_movement(delta, wish_dir, max_speed, acceleration):
	# only one of the raycasts is colliding, therefore should wallrun
	if left_cast.is_colliding() != right_cast.is_colliding():
		var tilt_dir = 1 if left_cast.is_colliding() else -1
		camera_controller.set_tilt(deg_to_rad(20) * tilt_dir)
		var projVel = Vector3(velocity.x, 0, velocity.z).dot(wish_dir)
		var accelVel = acceleration * delta
		if projVel + accelVel > max_speed:
			accelVel = max(0, max_speed - projVel)
		velocity += wish_dir.normalized() * accelVel
		velocity.y -= gravity * delta * 0.0625
	else:
		camera_controller.set_tilt(0)
		velocity.y -= gravity * delta * 0.25

func _walk(wish_dir, max_speed, acceleration):
	# Calculate current speed
	var speed = Vector3(velocity.x, 0, velocity.z)
	
	# Apply speed limit
	var speed_length = speed.length()
	if speed_length > max_speed:
		acceleration *= speed_length / max_speed
	
	# Calculate desired direction
	var direction = wish_dir * max_speed - speed
	
	# Apply minimum acceleration threshold
	var direction_length = direction.length()
	if direction_length < 0.5:
		acceleration *= direction_length / 0.5
	
	# Update velocity
	velocity += direction

func _jump():
	velocity.y += jump_up_speed
	can_jump = false
	var timer = get_tree().create_timer(0.2)
	timer.timeout.connect(reset_jump)

func _doublejump(wish_dir):
	velocity += wish_dir * air_speed * 2
	velocity.y = max(velocity.y + jump_up_speed, 0)

func _walljump():
	var jump_direction = (get_wall_normal() - transform.basis.z).normalized() * wall_jump_power
	velocity += jump_direction

func reset_jump():
	can_jump = true


@onready var head = $Head
# Grappling Hook Functions
func shoot_hook():
	var from = head.global_transform.origin
	var to = from + -head.global_transform.basis.z * max_distance
	var space_state = get_world_3d().direct_space_state
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

@onready var hook_line = $GrappleHook

func _retract_hook():
	var direction = (hook_target - global_transform.origin)
	var curve: Curve3D = hook_line.curve
	curve.set_point_position(1, direction)
	velocity += direction.normalized() * hook_speed * get_physics_process_delta_time()
	

	hook_line.global_rotation = Vector3.ZERO
	if global_transform.origin.distance_to(hook_target) < 1.0:
		is_hooked = false


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot_hook()
		gravity = default_gravity * 0.25
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		is_hooked = false
