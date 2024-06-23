extends StaticBody3D


@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@onready var parent: Map = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shape = BoxShape3D.new()
	shape.set_size(Vector3(parent.map_size, 1, parent.map_size))
	collision_shape.set_shape(shape)
	collision_shape.transform.origin -= Vector3(0, -0.5, 0)
	
	var mesh = PlaneMesh.new()
	mesh.set_size(Vector2(parent.map_size, parent.map_size))
	mesh_instance.set_mesh(mesh)
