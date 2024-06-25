class_name WallMovement
extends Node

# Wall
var wall_speed := 10.0
var wall_accel := 20.0
var wall_jump_power := 1.5

@onready var parent = $".." 
@onready var left_cast = $"../Head/LeftCast"
@onready var right_cast = $"../Head/RightCast"
@onready var camera_controller = $"../Head"

var can_walljump := true

func wall_movement(delta, wish_dir: Vector3):
	# only one of the raycasts is colliding, therefore should wallrun
	if left_cast.is_colliding() != right_cast.is_colliding():
		var tilt_dir = 1 if left_cast.is_colliding() else -1
		camera_controller.set_tilt(deg_to_rad(20) * tilt_dir)
		var projVel = Vector3(parent.velocity.x, 0, parent.velocity.z).dot(wish_dir)
		var accelVel = wall_accel * delta
		if projVel + accelVel > wall_speed:
			accelVel = max(0, wall_speed - projVel)
		parent.velocity += (wish_dir.normalized() * accelVel)
		parent.velocity.y -= (parent.gravity * delta * 0.0625)
		var wall_normal = parent.get_wall_normal()
		var velocity_projection = wall_normal * parent.velocity.dot(wall_normal)
		parent.velocity -= velocity_projection * 0.9
		parent.velocity += velocity_projection.normalized() * 0.2
	else:
		camera_controller.set_tilt(0)
		parent.velocity.y -= parent.gravity * delta * 0.25



func walljump():
	if can_walljump:
		var wall_normal = parent.get_wall_normal()
		var jump_direction = (wall_normal.normalized() * 2 - parent.transform.basis.z.normalized()).normalized() * wall_jump_power * 3
		var y_vel = parent.velocity.y 
		var y_vel_negation = abs(y_vel) if y_vel < 0 else 0
		parent.velocity += jump_direction + Vector3(0, wall_jump_power * 1.5 + y_vel_negation, 0)
		can_walljump = false
		var timer = get_tree().create_timer(0.3)
		timer.timeout.connect(_reset_walljump)

func _reset_walljump():
	can_walljump = true

func _on_player_new_state(old_state: int, _new_state: int) -> void:
	if old_state == 2:
		walljump()
