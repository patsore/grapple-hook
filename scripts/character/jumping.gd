class_name Jumping
extends Node

# Jump
var jump_up_speed := 4.2
var dash_speed := 6.0
var air_speed := 3.0

# Cooldowns
var can_jump := true
var can_d_jump := true

@onready var parent = $".."

func jump():
	parent.velocity.y += jump_up_speed
	can_jump = false
	var timer = get_tree().create_timer(0.2)
	timer.timeout.connect(reset_jump)

func doublejump(wish_dir):
	if can_d_jump:
		parent.velocity += wish_dir * air_speed * 2
		parent.velocity.y = max(parent.velocity.y + jump_up_speed, 0)
		can_d_jump = false
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(reset_d_jump)

func reset_jump():
	can_jump = true

func reset_d_jump():
	can_d_jump = true
