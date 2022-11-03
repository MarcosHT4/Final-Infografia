extends KinematicBody2D

var speed = 100
var movement = 20
var velocity = Vector2.ZERO

onready var dissapear_timer = $DissapearTimer
onready var state_machine = $AnimationTree.get("parameters/playback")

func _ready():
	dissapear_timer.start()
	

func _physics_process(delta):
	velocity.x = -movement
	move_and_slide(velocity*speed*delta)
	


func _on_DissapearTimer_timeout():
	
	dissapear_timer.stop()
	state_machine.travel("gone")
	queue_free()
	
	
