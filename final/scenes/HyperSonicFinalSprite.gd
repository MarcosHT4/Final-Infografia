extends Node2D

var velocity = Vector2(1000,0)
var move_into_screen = false

func _process(delta):
	if move_into_screen:
		position -= velocity*delta

func start_left_movement():
	move_into_screen = true
func stop_left_movement():
	move_into_screen = false			
