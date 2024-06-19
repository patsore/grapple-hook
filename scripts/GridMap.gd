@tool
extends GridMap

@export var map_size: int = 300
@export var street_spacing: int = 10
@export var park_likeliness: float = 0.1

# Define the different building heights and their probability distributions
@export var min_building_height: int = 2
@export var max_building_height: int = 8

@export var street_width = 3

func _ready():
	clear()
	set_streets_and_buildings()

func set_streets_and_buildings() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(map_size):
		for j in range(map_size):
			if get_cell_item(Vector3i(i, 0, j)) != INVALID_CELL_ITEM:
				continue
			
			var c_i = i % street_spacing
			var j_i = j % street_spacing
			if (c_i <= street_width / 2 && c_i >= -street_width / 2) || (j_i <= street_width / 2 && j_i >= -street_width / 2):
				set_cell_item(Vector3i(i, 0, j), 0)  # Street
				if c_i == 0 && j_i == 0:
					var is_park = rng.randf_range(0.0, 1.0) < park_likeliness
					if is_park:
						for i_p in range(i + 1, i + street_spacing):
							for j_p in range(j + 1, j + street_spacing):
								set_cell_item(Vector3i(i_p, 0, j_p), 1)  # Park
				continue
			
			var height = rng.randi_range(min_building_height, max_building_height)
			var width = rng.randi_range(1, street_spacing - 1 - c_i)
			var length = rng.randi_range(1, street_spacing - 1 - j_i)
			for h in range(height):
				for w in range(max(width, 1)):
					for l in range(max(length, 1)):
						var cell_position = Vector3i(i + w, h, j + l)
						set_cell_item(cell_position, 2)  # Building

func _process(delta: float) -> void:
	pass
