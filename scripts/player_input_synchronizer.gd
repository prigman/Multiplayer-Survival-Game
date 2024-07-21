extends MultiplayerSynchronizer

@export var input_direction := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
