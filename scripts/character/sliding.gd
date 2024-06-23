class_name Sliding
extends Node

@onready var parent: CharacterBody3D = $".."

@onready var collision_shape: CollisionShape3D = $"../CollisionShape3D"

@onready var camera_controller: CameraController = $"../Head"

var sliding_threshold = 2.5

var is_sliding = false

var original_rotation = 0.0

func crouch_or_slide():

	var parent_velocity = parent.velocity

	var floor_normal = parent.get_floor_normal()
	
	var too_slow = parent_velocity.length() < sliding_threshold
	

	if too_slow:
		is_sliding = false
	elif parent.is_on_floor():
		if !is_sliding:
			original_rotation = camera_controller.current_look.x
			is_sliding = true
		
		var velocity_direction: Vector3 = parent_velocity.normalized()
		var angle_cosine: float = floor_normal.dot(velocity_direction)
		var impact_angle: float = acos(angle_cosine)
		
		# Normalize the angle to a range from 0 to 1 (0 degrees = 0, 90 degrees = 1)
		var conversion_ratio: float = impact_angle / (PI / 2)

		# Define the direction the player is looking
		var look_direction: Vector3 = parent.global_transform.basis.z * -1
		
		# Calculate the vertical component of the velocity
		var vertical_velocity: float = parent_velocity.dot(floor_normal)
		
		# Reduce the vertical component by the conversion ratio
		var new_vertical_velocity: float = vertical_velocity * (1 - conversion_ratio)
		
		# Calculate the horizontal contribution from the vertical velocity
		var horizontal_velocity_contribution: float = vertical_velocity * conversion_ratio
		
		# Adjust the velocity
		parent_velocity -= (floor_normal * vertical_velocity)  # Remove the vertical component
		parent_velocity += (floor_normal * new_vertical_velocity)  # Add the reduced vertical component
		parent_velocity += (horizontal_velocity_contribution * look_direction) # Add the horizontal component
		
		# Update the player's velocity
		parent_velocity = lerp(parent_velocity, Vector3.ZERO, 0.015)
		parent.velocity = parent_velocity.rotated(Vector3.UP, camera_controller.current_look.x - original_rotation )
		original_rotation = camera_controller.current_look.x
	else:
		is_sliding = false
