extends Node3D

enum State{
	WALKING,
	RUNNING,
	IDLE,
}

var state

@onready var player = $".."
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.advance_expression_base_node = get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.running && player.velocity.length() >= 1.0:
		state = State.RUNNING
	elif player.velocity.length() <= 1.0:
		state = State.IDLE
	elif player.is_on_floor():
		state = State.WALKING
	else:
		state = State.IDLE

func _on_player_new_state(old_state: int, new_state: int) -> void:
	if old_state == 0:
		state = State.WALKING


