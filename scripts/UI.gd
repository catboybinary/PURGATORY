extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CurrentState.text = "current_state: " + str(player.logic.GeneralState.keys()[player.logic.current_state])
