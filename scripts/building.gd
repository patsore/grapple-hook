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
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var i = 0
	for x in range(grid_size):
		for y in range(grid_size):
			var height = randi_range(height_min, height_max)
			_generate_prism(surface_tool, 1, height, 1, x, y, i)
			i += 1
	# Calculate normals (for lighting)
	surface_tool.generate_tangents()
	
	#surface_tool.set_material(material)
	# Create the mesh
	var mesh = surface_tool.commit()
	# Create a MeshInstance to display the mesh
	self.mesh = mesh
	create_trimesh_collision()


func _generate_prism(surface_tool: SurfaceTool, width: int, height: int, length: int, x: int, y: int, i: int):
	
	var uvs = [
		Vector2(0, 0),  # 0
		Vector2(1, 0),  # 1
		Vector2(1, 1),  # 2

		Vector2(0, 0),  # 0
		Vector2(1, 1),  # 2
		Vector2(0, 1),  # 3

		Vector2(0, 0),  # 4
		Vector2(1, 1),  # 6
		Vector2(1, 0),  # 5

		Vector2(0, 0),  # 4
		Vector2(0, 1),  # 7
		Vector2(1, 1),  # 6

		Vector2(0, 0),  # 0
		Vector2(0, 1),  # 3
		Vector2(1, 1),  # 7

		Vector2(0, 0),  # 0
		Vector2(1, 1),  # 7
		Vector2(1, 0),  # 4

		Vector2(0, 0),  # 1
		Vector2(1, 0),  # 5
		Vector2(1, 1),  # 6

		Vector2(0, 0),  # 1
		Vector2(1, 1),  # 6
		Vector2(1, 0),  # 2

		Vector2(0, 1),  # 3
		Vector2(1, 1),  # 2
		Vector2(1, 1),  # 6

		Vector2(0, 1),  # 3
		Vector2(1, 1),  # 6
		Vector2(0, 1),  # 7

		Vector2(0, 0),  # 0
		Vector2(0, 0),  # 4
		Vector2(1, 0),  # 5

		Vector2(0, 0),  # 0
		Vector2(1, 0),  # 5
		Vector2(1, 0),  # 1
	]
	
	var normals = [
		Vector3(0, 0, -1),  # 0
		Vector3(0, 0, -1),  # 1
		Vector3(0, 0, -1),  # 2
		
		Vector3(0, 0, -1),  # 0
		Vector3(0, 0, -1),  # 2
		Vector3(0, 0, -1),  # 3
		
		Vector3(0, 0, 1),   # 4
		Vector3(0, 0, 1),   # 6
		Vector3(0, 0, 1),   # 5
		
		Vector3(0, 0, 1),   # 4
		Vector3(0, 0, 1),   # 7
		Vector3(0, 0, 1),   # 6
		
		Vector3(-1, 0, 0),  # 0
		Vector3(-1, 0, 0),  # 3
		Vector3(-1, 0, 0),  # 7
		
		Vector3(-1, 0, 0),  # 0
		Vector3(-1, 0, 0),  # 7
		Vector3(-1, 0, 0),  # 4
		
		Vector3(1, 0, 0),   # 1
		Vector3(1, 0, 0),   # 5
		Vector3(1, 0, 0),   # 6
		
		Vector3(1, 0, 0),   # 1
		Vector3(1, 0, 0),   # 6
		Vector3(1, 0, 0),   # 2
		
		Vector3(0, 1, 0),   # 3
		Vector3(0, 1, 0),   # 2
		Vector3(0, 1, 0),   # 6
		
		Vector3(0, 1, 0),   # 3
		Vector3(0, 1, 0),   # 6
		Vector3(0, 1, 0),   # 7
		
		Vector3(0, -1, 0),  # 0
		Vector3(0, -1, 0),  # 4
		Vector3(0, -1, 0),  # 5
		
		Vector3(0, -1, 0),  # 0
		Vector3(0, -1, 0),  # 5
		Vector3(0, -1, 0),  # 1
	]
	
	var vertices = [
		Vector3(0 + x, 0, 0 + y),  # 0
		Vector3(width + x, 0, 0 + y),   # 1
		Vector3(width + x, height, 0 + y),    # 2
		
		Vector3(0 + x, 0, 0 + y),  # 0
		Vector3(width + x, height, 0 + y),    # 2
		Vector3(0 + x, height, 0 + y),   # 3
		
		Vector3(0 + x, 0, length + y),   # 4
		Vector3(width + x, height, length + y),     # 6
		Vector3(width + x, 0, length + y),    # 5
		
		Vector3(0 + x, 0, length + y),   # 4
		Vector3(0 + x, height, length + y),   # 7
		Vector3(width + x, height, length + y),     # 6
		
		Vector3(0 + x, 0, 0 + y),  # 0
		Vector3(0 + x, height, 0 + y),   # 3
		Vector3(0 + x, height, length + y),   # 7
		
		Vector3(0 + x, 0, 0 + y),  # 0
		Vector3(0 + x, height, length + y),     # 7
		Vector3(0 + x, 0, length + y),   # 4
	
		Vector3(width + x, 0, 0 + y),   # 1
		Vector3(width + x, 0, length + y),    # 5
		Vector3(width + x, height, length + y),     # 6
		
		Vector3(width + x, 0, 0 + y),   # 1
		Vector3(width + x, height, length + y),     # 6
		Vector3(width + x, height, 0 + y),    # 2
		
		Vector3(0 + x, height, 0 + y),   # 3
		Vector3(width + x, height, 0 + y),    # 2
		Vector3(width + x, height, length + y),     # 6
		
		Vector3(0 + x, height, 0 + y),   # 3
		Vector3(width + x, height, length + y),     # 6
		Vector3(0 + x, height, length + y),     # 7
		
		Vector3(0 + x, 0, 0 + y),  # 0
		Vector3(0 + x, 0, length + y),   # 4
		Vector3(width + x, 0, length + y),    # 5
		
		Vector3(0 + x, 0, 0 + y),  # 0
		Vector3(width + x, 0, length + y),    # 5
		Vector3(width + x, 0, 0 + y),   # 1
	]
	# Define faces (triangles) of the cube
	var faces = [
		# Front face
		#0, 1, 2
		i * 8, i * 8 + 1, i * 8 + 2,
		#0, 2, 3
		i * 8, i * 8 + 2, i * 8 + 3,
		# Back face
		#4, 6, 5
		i * 8 + 4, i * 8 + 6, i * 8 + 5,
		#4, 7, 6
		i * 8 + 4, i * 8 + 7, i * 8 + 6,
		# Left face
		#0, 3, 7
		#0, 7, 4
		i * 8, i * 8 + 3, i * 8 + 7,
		i * 8, i * 8 + 7, i * 8 + 4,
		# Right face
		#1, 5, 6
		#1, 6, 2
		i * 8 + 1, i * 8 + 5, i * 8 + 6,
		i * 8 + 1, i * 8 + 6, i * 8 + 2,
		# Top face
		#3, 2, 6
		#3, 6, 7
		i * 8 + 3, i * 8 + 2, i * 8 + 6,
		i * 8 + 3, i * 8 + 6, i * 8 + 7,
		# Bottom face
		#0, 4, 5
		#0, 5, 1
		i * 8, i * 8 + 4, i * 8 + 5,
		i * 8, i * 8 + 5, i * 8 + 1
	]
	
	# Set vertices
	var j = 0
	for vertex in vertices:
		#surface_tool.set_uv(uvs[j])
		surface_tool.set_normal(normals[j])
		surface_tool.set_uv(uvs[j])
		j += 1
		surface_tool.add_vertex(vertex)
	# Set faces (triangles)
	#for face in faces:
		#surface_tool.add_index(face)
