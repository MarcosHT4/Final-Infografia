extends KinematicBody2D

onready var state_machine = $AnimationTree.get("parameters/playback")
onready var audio_player = $Effects
onready var shoot_timer = $ShootTimer
onready var sprite = $Sprite
onready var delete_timer = $DeleteTimer
var start_attack = false
var dead = false
var finished = false
var flip_pellet = false
var entered_area = false

var enemy_dead_audio = preload("res://assets/enemy_audio/enemy_dead.wav")

func _physics_process(delta):
	if start_attack and not finished:
		shoot_timer.start()
		start_attack = false
	if dead:
		state_machine.travel("exploding")	
		state_machine.travel("gone")
		change_and_play_audio(enemy_dead_audio)
		delete_timer.start()
		dead = false
		finished = true
		
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()			

func shoot():
	var pellet_scene = preload("res://scenes/Pellet.tscn")
	var pellet_node = pellet_scene.instance()
	pellet_node.position.x = position.x + 150
	pellet_node.position.y = position.y + 80
	pellet_node.scale.x = 0.2
	pellet_node.scale.y = 0.2
	if flip_pellet:
		pellet_node.movement = -pellet_node.movement
		pellet_node.position.x +=10
	else:
		pellet_node.position.x -= 20	
	flip_pellet = not flip_pellet
	get_parent().add_child(pellet_node)
		
	

func _on_Followbox_area_entered(area):
	state_machine.travel('attack')
	start_attack = true
	
	

func _on_Hurtbox_area_entered(area):
	dead = true


func _on_ShootTimer_timeout():
	if not finished:
		shoot()


func _on_DeleteTimer_timeout():
	queue_free()
