extends StaticBody2D

var destroyed = false
var show_destroyed_monitor


onready var state_machine = $AnimationTree.get("parameters/playback")
onready var audio_player = $Effects


var destroyed_monitor_audio = preload("res://assets/enemy_audio/enemy_dead.wav")

func _on_Hitbox_area_entered(area):
	if not destroyed:
		state_machine.travel("exploded")
		position.y+=15
		change_and_play_audio(destroyed_monitor_audio)
		destroyed = true
		
		
		
		
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()			
			



	
