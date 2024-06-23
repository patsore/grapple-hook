class_name WorldBorder
extends Node3D

@onready var parent: Map = $".."
@onready var world_size = parent.map_size

func _ready() -> void:
	# Create the boundaries
	create_boundary(Vector3(0, 0, -world_size / 2), Vector3(world_size, world_size, 1)) # Back
	create_boundary(Vector3(0, 0, world_size / 2), Vector3(world_size, world_size, 1))  # Front
	create_boundary(Vector3(-world_size / 2, 0, 0), Vector3(1, world_size, world_size)) # Left
	create_boundary(Vector3(world_size / 2, 0, 0), Vector3(1, world_size, world_size))  # Right

func create_boundary(position: Vector3, size: Vector3) -> void:
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	
	static_body.collision_layer = 2
	
	box_shape.size = size
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	static_body.transform.origin = position
	
	add_child(static_body)
