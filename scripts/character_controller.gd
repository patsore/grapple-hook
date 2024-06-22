extends CharacterBody3D

var default_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = default_gravity

# Ground
var walk_speed := 4.0
var run_speed := 6.0
var gr_accel := 5.0

# Air
var air_speed := 3.0
var air_accel := 20.0
var max_air_velocity := 20.0

# States
var running := false

enum State {
	WALKING,
	FLYING,
	WALLRUNNING,
}

@onready var camera_controller: CameraController = $Head 
@onready var wall_movement: WallMovement = $WallMovement

@onready var jumping: Jumping = $Jumping
@onready var sliding: Sliding = $Sliding

@onready var debug_label = $Head/MainCamera/Control/Label

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

signal new_state(old_state: State, new_state: State)

func _physics_process(delta):
	var state = _compute_state()
	on_new_state(state)
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
			wall_movement.wall_movement(delta, wish_dir)
	
	if Input.is_action_just_pressed("move_crouch") && running && is_on_floor():
		#add boost
		pass

	if Input.is_action_pressed("move_crouch"):
		sliding.crouch_or_slide()
		pass

	if Input.is_action_just_pressed("move_jump"):
		match state:
			State.WALKING: 
				jumping.jump()
			State.FLYING:
				jumping.doublejump(wish_dir) 
			State.WALLRUNNING:
				wall_movement.walljump()

	debug_label.text = "Speed: %s, state: %s" % [velocity, state] 
	
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

func _walk(wish_dir, max_speed, acceleration):
	if Input.is_action_pressed("move_crouch") && velocity.length() > 2.5:
		#do not walk when sliding
		return
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

var old_state: State = State.WALKING

func on_new_state(state: State) -> void:
	if old_state != state:
		new_state.emit(old_state, state)
		old_state = state

func _on_new_grappling_hook_hook_attached(point_of_contact: Vector3) -> void:
	gravity = default_gravity * 0.25 # Replace with function body.

func _on_new_grappling_hook_hook_detached() -> void:
	gravity = default_gravity # Replace with function body.
