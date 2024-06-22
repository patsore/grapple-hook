@tool
extends CSGPolygon3D

var circle_points: PackedVector2Array

@export var radius = 0.2
@export var segments = 8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(segments):
		var angle = 2 * PI * i / segments
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		var point = Vector2(x, y)
		circle_points.append(point)
		
	polygon = circle_points
	
