extends "res://scenes/FollowerBadnik.gd"


func follow_player():
	velocity = Vector2(position.x, position.y).direction_to(Vector2(player.position.x+523, player.position.y+149))
	velocity.y = 0


	


