class_name WallMovement
extends Node

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
var wall_jump_power := 1.5
var wall_ban := 0.0
var wr_timer := 0.0
var wall_stick_timer := 0.0

@onready var parent = $".." 
@onready var left_cast = $"../Head/LeftCast"
@onready var right_cast = $"../Head/RightCast"
@onready var camera_controller = $"../Head"

func wall_movement(delta, wish_dir):
	# only one of the raycasts is colliding, therefore should wallrun
	if left_cast.is_colliding() != right_cast.is_colliding():
		var tilt_dir = 1 if left_cast.is_colliding() else -1
		camera_controller.set_tilt(deg_to_rad(20) * tilt_dir)
		var projVel = Vector3(parent.velocity.x, 0, parent.velocity.z).dot(wish_dir)
		var accelVel = wall_accel * delta
		if projVel + accelVel > wall_speed:
			accelVel = max(0, wall_speed - projVel)
		parent.velocity += wish_dir.normalized() * accelVel
		parent.velocity.y -= parent.gravity * delta * 0.0625
	else:
		camera_controller.set_tilt(0)
		parent.velocity.y -= parent.gravity * delta * 0.25

func walljump():
	var jump_direction = (parent.get_wall_normal() * 2 - parent.transform.basis.z) * wall_jump_power * 3
	parent.velocity += jump_direction + Vector3(0, wall_jump_power, 0)
