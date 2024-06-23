@tool
class_name Building
extends MeshInstance3D

# Dimensions of each prism
var height_min: float = 1.0
var height_max: float = 5.0

# Size of the grid
var grid_size: int = 3  # Adjust this for different grid sizes

func _init(grid_size: int, height_min: int, height_max: int):
	self.grid_size = grid_size
	self.height_max = height_max
	self.height_min = height_min


func _ready():
	# Create a new ArrayMesh
	var mesh = ArrayMesh.new()

	# Generate vertices
	var vertices = generate_vertices()

	# Generate triangles (indices)
	var indices = generate_triangles()

	# Create arrays for vertices and indices
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	# Add surface from arrays
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = mesh
	create_trimesh_collision()

# Function to generate vertices of the prisms in a grid
func generate_vertices() -> PackedVector3Array:
	var vertices = PackedVector3Array()

	for x in range(grid_size):
		for z in range(grid_size):
			var height = randi_range(height_min, height_max)
			var half_w = 0.5
			var half_h = height / 2.0
			var half_l = 0.5

			# Calculate the top center position of the prism
			var offset = Vector3(x * 1.0, half_h, z * 1.0)  # Top center at y = 0

			vertices.append_array(PackedVector3Array([
				Vector3(-half_w, half_h, -half_l) + offset,   # 0
				Vector3(half_w, half_h, -half_l) + offset,    # 1
				Vector3(half_w, -half_h, -half_l) + offset,   # 2
				Vector3(-half_w, -half_h, -half_l) + offset,  # 3
				Vector3(-half_w, half_h, half_l) + offset,    # 4
				Vector3(half_w, half_h, half_l) + offset,     # 5
				Vector3(half_w, -half_h, half_l) + offset,    # 6
				Vector3(-half_w, -half_h, half_l) + offset    # 7
			]))
	
	return vertices

# Function to generate triangles (indices) of the prisms
func generate_triangles() -> PackedInt32Array:
	var indices = PackedInt32Array()
	var vertex_index = 0

	for x in range(grid_size):
		for z in range(grid_size):
			var base_index = vertex_index

			indices.append_array(PackedInt32Array([
				# Top face (inverted order for upside down orientation)
				base_index + 0, base_index + 3, base_index + 2, base_index + 2, base_index + 1, base_index + 0,
				# Bottom face
				base_index + 4, base_index + 5, base_index + 6, base_index + 6, base_index + 7, base_index + 4,
				# Front face
				base_index + 4, base_index + 0, base_index + 1, base_index + 1, base_index + 5, base_index + 4,
				# Back face
				base_index + 7, base_index + 6, base_index + 2, base_index + 2, base_index + 3, base_index + 7,
				# Right face
				base_index + 5, base_index + 1, base_index + 2, base_index + 2, base_index + 6, base_index + 5,
				# Left face
				base_index + 7, base_index + 3, base_index + 0, base_index + 0, base_index + 4, base_index + 7
			]))

			vertex_index += 8  # Move to the next prism's vertices

	return indices
