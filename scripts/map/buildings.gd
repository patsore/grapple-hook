extends Node3D

@onready var parent: Map = $".."

@onready var noise = FastNoiseLite.new()

@export var max_building_height = 50
@export var min_building_height = 5

@export var commercial_building_probability = 0.3
@export var residential_building_probability = 0.5
@export var park_probability = 0.2

func _ready():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05

	var starting_coordinate = Vector2(-parent.map_size / 2, -parent.map_size / 2)
	for x in range(-parent.map_size / 2, parent.map_size / 2):
		if x % parent.street_spacing != 0:
			continue
		for y in range(-parent.map_size / 2, parent.map_size / 2):
			if y % parent.street_spacing == 0:
				create_building(x, y)

func create_building(x: float, y: float):
	var height = abs(noise.get_noise_2d(x, y)) * (max_building_height)
	
	if height <= min_building_height:
		create_park(x, y)
		return
	if height <= max_building_height - min_building_height:
		create_residential_building(x, y, height)
		return
	else:
		create_residential_building(x, y, height)
		return

func create_commercial_building(x: float, y: float, height: float):
	var building = MeshInstance3D.new()
	building.transform.origin = Vector3(x, height / 2, y)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(parent.street_spacing - parent.street_width, height, parent.street_spacing - parent.street_width)
	building.mesh = mesh
	add_child(building)

func create_residential_building(x: float, y: float, height: float):
	var building = MeshInstance3D.new()
	building.transform.origin = Vector3(x, height / 2, y)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(parent.street_spacing - parent.street_width, height, parent.street_spacing - parent.street_width)
	mesh.subdivide_depth = 1
	mesh.subdivide_height = 1
	mesh.subdivide_width = 1
	building.mesh = mesh
	add_child(building)

func create_park(x: float, y: float):
	var park = MeshInstance3D.new()
	park.transform.origin = Vector3(x, 0.05, y)  # slightly above the ground
	var mesh = BoxMesh.new()
	mesh.size = Vector3(parent.street_spacing - parent.street_width, 0.1, parent.street_spacing - parent.street_width)
	park.mesh = mesh
	add_child(park)
