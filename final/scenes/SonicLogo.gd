extends Node2D

onready var animation_player = $AnimationPlayer
var move_to_right = false
var change_pose = false

func _ready():
	animation_player.play("appear")

func _process(delta):
	if animation_player.current_animation == "appear":
		if position.y > -60:
			position.y -= 1
	
	if not move_to_right and animation_player.current_animation != "appear" and animation_player.current_animation != "change_pose": 
		animation_player.play("move_to_right")
		move_to_right = true
	if animation_player.current_animation =="move_to_right":
		position.x +=1
	
	if not change_pose and animation_player.current_animation != "appear" and animation_player.current_animation != "move_to_right":
		animation_player.play("change_pose")
		change_pose = true	
		
			
	
	
	
