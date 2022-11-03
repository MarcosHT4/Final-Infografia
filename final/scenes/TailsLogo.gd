extends Node2D

onready var animation_player = $AnimationPlayer
var appear = false
var move_to_left = false
var change_pose = false


func _ready():
	animation_player.play("wait_for_sonic")
func _process(delta):
	if animation_player.current_animation == "appear":
		position.y-=1
	if animation_player.current_animation =="move_to_left":
		position.x -=1
	if not appear and animation_player.current_animation == "":
		animation_player.play("appear")
		appear = true
	if not move_to_left and appear and animation_player.current_animation == "":
		animation_player.play("move_to_left")
		move_to_left = true
	if not change_pose and appear and move_to_left and animation_player.current_animation == "":
		animation_player.play("change_pose")
		change_pose = true
		
	
		
