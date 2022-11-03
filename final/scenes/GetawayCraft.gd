extends KinematicBody2D

const MAX_SPEED = 180
const ACCEL = 180
const movement = 180

var velocity = Vector2.ZERO 
var direction = Vector2.ZERO
var remaining_turrets = 3
var exploding = false
var gone = false

onready var getaway_craft_collision = $GetawayCraftCollision
onready var getaway_craft_shield = $GetawayCraftShield
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var audio_player = $Effects
onready var exploding_timer = $ExplodingTimer

var hit_sound = preload("res://assets/player_audio/boss_hit.wav")
var multi_hit_sound = preload("res://assets/player_audio/multi_boss_hit.mp3")

signal first_boss_dead(final_position)

func _ready():
	for node in get_children():
		if "Turret" in node.name:
			node.connect("turret_exploded", self, "on_turret_exploded")

func _physics_process(delta):
	if not gone:
		direction.x = movement
		direction = direction.normalized()
		velocity = velocity.move_toward(direction*MAX_SPEED, ACCEL*delta)
		velocity = move_and_slide(velocity, Vector2.UP)
	if exploding:
		velocity.y+=5
	
func on_turret_exploded():
	if remaining_turrets > 0:
		remaining_turrets-=1
		for turret in get_children():
			if "Turret" in turret.name:
				turret.shoot_timer.wait_time -= 0.3
		if remaining_turrets == 0:
			state_machine.travel('flying_turrets_gone')
			
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()					
				
	
func _on_Hurtbox_area_entered(area):
	exploding = true
	state_machine.travel('exploding')
	exploding_timer.start()
	change_and_play_audio(multi_hit_sound)


func _on_ExplodingTimer_timeout():
	exploding_timer.stop()
	audio_player.stop()
	state_machine.travel("gone")
	velocity = Vector2.ZERO
	exploding = false
	emit_signal("first_boss_dead", position)
	gone = true
	queue_free()
