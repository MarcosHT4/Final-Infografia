extends CanvasLayer

func change_scene(target, area):
	var animation_to_play
	match area:
		1:
			animation_to_play = "dissolve"
		2:
			animation_to_play = "dissolve_2"
		3:
			animation_to_play = "dissolve_3"					
	$AnimationPlayer.play(animation_to_play)
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(target)
	$AnimationPlayer.play_backwards(animation_to_play)
	
		
