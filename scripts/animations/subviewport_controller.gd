extends SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	get_tree().get_root().size_changed.connect(resize)

func resize():
	var screen_size = get_window().size
	
	size = screen_size
	
