extends Node3D

@onready var parent: Map = $".."

@onready var noise = FastNoiseLite.new()

@export var max_building_height = 5
@export var min_building_height = 1
@export var building_scale = 3
@export var building_material = load("res://addons/kenney_prototype_tools/materials/purple/material_02.tres")

func _ready():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.09

	var starting_coordinate = Vector2(-parent.map_size / 2, -parent.map_size / 2)
	for x in range(-parent.map_size / 2, parent.map_size / 2):
		if x % parent.street_spacing != 0:
			continue
		for y in range(-parent.map_size / 2, parent.map_size / 2):
			if y % parent.street_spacing == 0:
				var noise_value = noise.get_noise_2d(x, y)
				
				# Adjust the heights relative to the noise value
				var noise_adjusted_height_min = min_building_height + (noise_value + 1) / 2 * (max_building_height - min_building_height)
				var noise_adjusted_height_max =  noise_adjusted_height_min + (max_building_height - min_building_height)

				var building = Building.new(parent.street_spacing - parent.street_width, noise_adjusted_height_min, noise_adjusted_height_max, building_scale)
				building.transform.origin = Vector3(x, 0, y)

				add_child(building)
				building.mesh.surface_set_material(0, building_material)
