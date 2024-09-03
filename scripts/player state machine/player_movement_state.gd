class_name PlayerMovementState
extends State

const ACCELERATION := .2
const DECCELERATION := 1.5

var player : Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
