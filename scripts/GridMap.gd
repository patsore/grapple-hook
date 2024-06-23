@tool
extends GridMap

@export var map_size: int = 300
@export var street_spacing: int = 10
@export var park_likeliness: float = 0.1

# Define the different building heights and their probability distributions
@export var min_building_height: int = 2
@export var max_building_height: int = 8

@export var street_width = 3
@export var noise_scale: float = 0.1

var noise = FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale

	clear()
	set_streets_and_buildings()

func set_streets_and_buildings() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()


	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var mesh = BoxMesh.new()  # Simple cube mesh for the buildings
	multimesh.mesh = mesh

	var instance_count = 0

	for i in range(map_size):
		for j in range(map_size):
			if get_cell_item(Vector3i(i, 0, j)) != INVALID_CELL_ITEM:
				continue

			var c_i = i % street_spacing
			var j_i = j % street_spacing
			if (c_i <= street_width / 2 and c_i >= -street_width / 2) or (j_i <= street_width / 2 and j_i >= -street_width / 2):
				set_cell_item(Vector3i(i, 0, j), 0)  # Street
				if c_i == 0 and j_i == 0:
					var is_park = rng.randf_range(0.0, 1.0) < park_likeliness
					if is_park:
						for i_p in range(i + 1, i + street_spacing):
							for j_p in range(j + 1, j + street_spacing):
								set_cell_item(Vector3i(i_p, 0, j_p), 1)  # Park
				continue

			var height = min_building_height + int((max_building_height - min_building_height) * noise.get_noise_2d(i, j))
			var width = rng.randi_range(1, street_spacing - 1 - c_i)
			var length = rng.randi_range(1, street_spacing - 1 - j_i)
			for h in range(height):
				for w in range(max(width, 1)):
					for l in range(max(length, 1)):
						var cell_position = Vector3i(i + w, h, j + l)
						multimesh.set_instance_transform(instance_count, Transform(Basis(), cell_position))
						instance_count += 1

	multimesh.instance_count = instance_count
	add_child(mesh_instance)

func generate_building():
	pass

func generate_park():
	pass

