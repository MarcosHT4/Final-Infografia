extends KinematicBody2D

const MAX_SPEED = 180
const ACCEL = 180
const movement = 180

var velocity = Vector2.ZERO 
var direction = Vector2.ZERO
var hp = 5
var exploding = false
var gone = false
var start_animation_check = false
var start_shooting = false

var hit_sound = preload("res://assets/player_audio/boss_hit.wav")
var multi_hit_sound = preload("res://assets/player_audio/multi_boss_hit.mp3")

onready var audio_player = $Effects
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var animation_player = $AnimationPlayer
onready var exploding_timer = $ExplodingTimer
onready var shoot_timer = $ShootTimer

signal shoot_missile(second_boss_postion)
signal second_boss_defeated()



func _physics_process(delta):
	
	if not gone:
		direction.x = movement
		direction = direction.normalized()
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCEL*delta)
		velocity = move_and_slide(velocity, Vector2.UP)
	if start_shooting:
		shoot_timer.start()
		start_shooting = false	
	if exploding:
		velocity.y+=5
	if not start_animation_check:
		start_shooting = true
		start_animation_check = true
		

func spawn_animation():
	velocity.y-=30
	velocity.x+=40

func stop_animation():
	velocity.y +=90
		
		
func _on_Hurtbox_area_entered(area):
	if not gone:
		if hp >=1:
			change_and_play_audio(hit_sound)
			hp-=1
			if hp <=0:
				exploding = true
				shoot_timer.stop()
				state_machine.travel('exploding')
				exploding_timer.start()
				change_and_play_audio(multi_hit_sound)
				emit_signal("second_boss_defeated")

func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()			
	


func _on_ExplodingTimer_timeout():
	exploding_timer.stop()
	audio_player.stop()
	state_machine.travel('gone')
	velocity = Vector2.ZERO
	exploding = false
	gone = true


func _on_ShootTimer_timeout():
	emit_signal("shoot_missile", position)
	
func finish_start_animation():
	start_animation_check = true	
