extends Node2D

var velocity = Vector2(110,0)

func _process(delta):
	position+=velocity*delta
