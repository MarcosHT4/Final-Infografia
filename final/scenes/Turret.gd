extends KinematicBody2D

var hp = 3
var invincibility = false
var dead = false
var finished = false
var velocity = Vector2.ZERO 
var direction = Vector2.ZERO


onready var invincibility_timer = $InvincibilityTimer
onready var shoot_timer = $ShootTimer
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var animation_player = $AnimationPlayer
onready var audio_player = $Effects

var hit_sound = preload("res://assets/player_audio/boss_hit.wav")

signal generate_bullet(position)
signal turret_exploded()

func _ready():
	shoot_timer.start()

func _physics_process(delta):
	
	if dead:
		state_machine.travel("exploding")
		state_machine.travel("gone")
		dead = false
		emit_signal("turret_exploded")
		finished = true
		
	
func _on_Hurtbox_area_entered(area):
	if not invincibility and not dead:
		if hp >= 1:
			hp -=1
			change_and_play_audio(hit_sound)
			state_machine.travel("hit")
			if hp > 0:
				invincibility_timer.start()
				invincibility = true
			else:
				dead = true	
			
func shoot():
	emit_signal("generate_bullet", global_position)

func _on_InvincibilityTimer_timeout():
	invincibility_timer.stop()
	state_machine.travel("static")
	invincibility = false
	
	
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()			
	


func _on_ShootTimer_timeout():
	if not finished:
		shoot()
	else:
		shoot_timer.stop()	
