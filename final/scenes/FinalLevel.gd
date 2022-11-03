extends Node2D


onready var super_sonic = $SuperSonic
onready var generate_meteor_timer = $GenerateMeteorTimer
onready var camera_super_sonic:Camera2D = $SuperSonic/Camera2D
onready var first_phase_duration_timer = $FirstPhaseDurationTimer
onready var game_over_timer = $GameOverTimer
onready var game_over_label = $GameOverLabel
onready var audio_player = $Song
onready var generate_missile_timer = $GenerateMissileTimer
onready var lower_limit = $Limit2/RoofCollision
onready var game_won_timer = $GameWonTimer
onready var show_hyper_sonic_sprite_timer = $ShowHyperSonicSpriteTimer


onready var game_over_audio = preload("res://assets/main/game_over.wav")
onready var game_won_audio = preload("res://assets/ending/ending_music.mp3")

var meteor_flag = false
var meteor_position = Vector2.ZERO
var boss_position = Vector2.ZERO
var first_phase = true
var third_phase = false
var spawn_boss = false
var label_position = Vector2.ZERO
var width_with_offset = (ProjectSettings.get("display/window/size/width")/2) - 480
var height_with_offset = (ProjectSettings.get("display/window/size/height")/2) - 90
var boss:KinematicBody2D = null

var second_boss_missiles_shot = 0

var random_meteor_flag = 0
var rng = RandomNumberGenerator.new()


func _ready():
	generate_meteor_timer.start()
	first_phase_duration_timer.start()
	super_sonic.connect("player_dead", self, "show_game_over")
	super_sonic.connect("hyper_sonic_has_stopped_falling", self, "spawn_final_scenes")

func _process(delta):
	if first_phase or third_phase:
		create_meteor()
	if spawn_boss:
		create_boss()	
		spawn_boss = false
		
	if not audio_player.playing and (audio_player.stream == game_won_audio or audio_player.stream == game_over_audio):
		get_tree().change_scene("res://scenes/TitleScreen.tscn")	

func create_meteor():
	if meteor_flag:
		rng.randomize()
		var current_meteor = preload("res://scenes/BigMeteor.tscn")
		random_meteor_flag = int(rng.randf_range(0,3))
		match random_meteor_flag:
			0:
				current_meteor = preload("res://scenes/BigMeteor.tscn")
			1:
				current_meteor = preload("res://scenes/MediumMeteor.tscn")
			2:
				current_meteor = preload("res://scenes/SmallMeteor.tscn")
		var current_meteor_node = current_meteor.instance()	
		meteor_position = camera_super_sonic.get_camera_screen_center()
		meteor_position.y -=250
		current_meteor_node.position = meteor_position
		add_child(current_meteor_node)
		meteor_flag = false

func create_boss():
	var boss = preload("res://scenes/GetawayCraft.tscn")		
	var boss_node = boss.instance()
	boss_position = camera_super_sonic.get_camera_screen_center()
	boss_position.x+=500
	boss_position.y = height_with_offset+50
	boss_node.position = boss_position 
	boss = boss_node
	boss.connect("first_boss_dead", self, "create_second_boss")
	for node in boss.get_children():
		if "Turret" in node.name:
			node.connect("generate_bullet", self, "create_bullet")	
	add_child(boss_node)


func create_second_boss(boss_initial_position):
	third_phase = true
	generate_meteor_timer.start()
	generate_meteor_timer.wait_time = 0.7
	super_sonic.state_machine.travel("hyper_sonic_transformation")
	super_sonic.MAX_SPEED = 500
	super_sonic.ACCEL = 1000
	var boss = preload("res://scenes/EggBomber.tscn")
	var boss_node = boss.instance()
	boss_node.position = boss_initial_position
	boss_node.connect("shoot_missile", self, "shoot_missile_sequence")
	boss_node.connect("second_boss_defeated", self, "end_level")
	add_child(boss_node)	

func create_bullet(turret_position):
	var bullet = preload("res://scenes/TurretBullet.tscn")
	var bullet_node = bullet.instance()
	bullet_node.position = turret_position
	add_child(bullet_node)
	
	
func shoot_missile_sequence(second_boss_position):
	if generate_missile_timer.is_stopped():
		generate_missile_timer.start()
	boss_position = second_boss_position	
	boss_position.y -=200
	boss_position.x +=180
	
func create_missile():
	var missile = preload("res://scenes/Missile.tscn")	
	var missile_node = missile.instance()
	missile_node.position = boss_position
	add_child(missile_node)

func show_game_over(goal_position):
	label_position = goal_position	
	label_position.x += width_with_offset-200
	label_position.y += height_with_offset - 250
	game_over_timer.start()	
	
func end_level():
	third_phase = false
	generate_meteor_timer.stop()
	super_sonic.doomsday_zone_cleared = true	
	super_sonic.state_machine.travel('end')
	super_sonic.falling_down_timer.call_deferred("start")
	super_sonic.lose_rings_timer.call_deferred("stop")
	lower_limit.call_deferred("set_disabled", true)
	
func spawn_final_scenes():
	change_and_play_audio(game_won_audio)
	var tails_in_tornado = preload("res://scenes/TailsInTornado.tscn")
	var tails_in_tornado_node = tails_in_tornado.instance()
	tails_in_tornado_node.position = super_sonic.position
	tails_in_tornado_node.position.x -= 300
	tails_in_tornado_node.position.y += 50
	add_child(tails_in_tornado_node)
	game_won_timer.start()
	
	
		
	

func _on_GenerateMeteorTimer_timeout():
	meteor_flag = true
	
	
func _on_FirstPhaseDurationTimer_timeout():
	
	first_phase_duration_timer.stop()
	first_phase = false
	spawn_boss = true
	


func _on_GameOverTimer_timeout():
	end_game(game_over_timer, game_over_label, label_position,game_over_audio)
	
func end_game(timer, label, label_final_position, audio):

	timer.stop()
	label.visible = true
	label.set_global_position(label_final_position)
	change_and_play_audio(audio)	
	
func change_and_play_audio(audio):
	audio_player.stream = audio
	audio_player.play()		
	
func _on_GenerateMissileTimer_timeout():
	boss_position.y += 50
	boss_position.x +=100
	if second_boss_missiles_shot < 3:
		create_missile()
		second_boss_missiles_shot +=1
	else:
		generate_missile_timer.stop()	
		second_boss_missiles_shot = 0


func _on_GameWonTimer_timeout():
	game_won_timer.stop()
	super_sonic.final_position = super_sonic.position
	super_sonic.lock_camera = true
	super_sonic.fly_out_of_screen = true
	show_hyper_sonic_sprite_timer.start()
	
	
	


func _on_ShowHyperSonicSpriteTimer_timeout():
	show_hyper_sonic_sprite_timer.stop()
	var hyper_sonic_final_sprite = preload("res://scenes/HyperSonicFinalSprite.tscn")
	var hyper_sonic_final_sprite_node = hyper_sonic_final_sprite.instance()
	hyper_sonic_final_sprite_node.position = super_sonic.camera.global_position
	hyper_sonic_final_sprite_node.position.y+=350
	hyper_sonic_final_sprite_node.position.x+=800
	hyper_sonic_final_sprite_node.scale = Vector2(2,2)
	add_child(hyper_sonic_final_sprite_node)
	
