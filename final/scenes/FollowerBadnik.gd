extends KinematicBody2D

export var speed = 5000
var velocity  = Vector2.ZERO

var path = []
var level_navigation:Navigation2D = null
var player:KinematicBody2D = null
var dead = false
var finished = false
var follow_player = false

onready var hurtbox_area = $Hurtbox/HurtboxShape
onready var hitbox_area = $Hitbox/HitboxShape
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var animation_player = $AnimationPlayer
onready var audio_player = $Effects
onready var delete_timer = $DeleteTimer

var enemy_dead_audio = preload("res://assets/enemy_audio/enemy_dead.wav")

func _ready():
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
func _physics_process(delta):
	move_and_slide(velocity*speed*delta)
	
	if player !=null and not finished and follow_player:
		if get_slide_count() != 0:
			follow_player()
		else:
			velocity.y = 5
		if velocity.x < 0:
			$Sprite.scale.x = 1
		elif velocity.x > 0:
			$Sprite.scale.x = -1
	
		
		
	if dead:
		velocity = Vector2.ZERO
		state_machine.travel("exploding")
		state_machine.travel("gone")
		change_and_play_audio(enemy_dead_audio)
		delete_timer.start()
		finished = true
		dead = false
		
func follow_player():
	velocity = Vector2(position.x, position.y).direction_to(Vector2(player.position.x, player.position.y))
	velocity.y = 0
			
		
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()		

func _on_Hurtbox_area_entered(area):
	dead = true
	


func _on_Followbox_area_entered(area):
	follow_player = true


func _on_DeleteTimer_timeout():
	queue_free()
	
