extends KinematicBody2D

var MAX_SPEED = 250
var ACCEL = 500
const FRICTION = 1

var ring_counter = 50
var collided_with_meteor = false
var collided_with_second_boss = false
var velocity = Vector2.ZERO
var lock_camera = false
var dead = false
var final_position = Vector2.ZERO
var dead_audio = preload("res://assets/player_audio/dead.wav")
var sonic_transforming = false
var doomsday_zone_cleared = false
var falling_down_stopped = false
var fly_out_of_screen = false

signal player_dead(final_position)
signal hyper_sonic_has_stopped_falling()


onready var state_machine = $AnimationTree.get("parameters/playback")
onready var ring_label = $RingCounter
onready var lose_rings_timer = $LoseRingsTimer
onready var sprite = $Sprite
onready var super_sonic_shape = $SuperSonicShape
onready var audio_player = $Effects
onready var camera = $Camera2D
onready var falling_down_timer = $FallingDownTimer
func _ready():
	ring_label.text = str("Rings: " + str(ring_counter))
	lose_rings_timer.start()

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO and not doomsday_zone_cleared:
		velocity = velocity.move_toward(input_vector*MAX_SPEED, ACCEL*delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if not sonic_transforming:		
		velocity = move_and_slide(velocity)
	
	if collided_with_meteor:
		velocity.x-=400
		if collided_with_second_boss:
			velocity.x -=100
			collided_with_second_boss = false
		collided_with_meteor = false
		
		
	if ring_counter == 0:
		lose_rings_timer.stop()
		sprite.rotate(90)
		velocity.y += 30
		super_sonic_shape.disabled = true
		if not dead:
			game_over()
	
	if lock_camera:
		camera.global_position = Vector2(final_position.x - 265, final_position.y -350)
		
			
	check_collisions()
	
	if doomsday_zone_cleared:
		if not falling_down_stopped:
			velocity.y=250
		else:
			velocity.y = 0	
		if not fly_out_of_screen:	
			velocity.x = 100
		else:
			velocity.x = 700
			
func check_collisions():
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		var body = collision.collider
		if ("BigMeteor" in body.name or  "MediumMeteor" in body.name or  "SmallMeteor" in body.name or "TurretBullet" in body.name
		or "EggBomber" in body.name or "Missile" in body.name):
			if "EggBomber" in body.name:
				collided_with_second_boss = true
			collided_with_meteor = true
			

func game_over():
	final_position = position
	change_and_play_audio(dead_audio)
	ring_label.visible = false
	lock_camera = true
	emit_signal("player_dead", final_position)
	dead = true
					
			
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()				
		
func _update_ring_count():	
	ring_label.text = str("Rings: " + str(ring_counter))

func _on_RingCollection_area_entered(area):
	ring_counter +=1
	_update_ring_count()

func stop_movement_while_transforming():
	sonic_transforming = true

func restart_movement():
	sonic_transforming = false		
	

func _on_LoseRingsTimer_timeout():
	ring_counter -=1
	_update_ring_count()


func _on_FallingDownTimer_timeout():
	ring_label.visible = false
	falling_down_timer.stop()
	falling_down_stopped = true
	emit_signal("hyper_sonic_has_stopped_falling")
	
	
