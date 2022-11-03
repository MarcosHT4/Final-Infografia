extends KinematicBody2D


const MAX_SPEED = 200
const ACCEL = 200
const movement = 5000

var velocity = Vector2.ZERO 
var direction = Vector2.ZERO
var dissapear = false
var player_pos = Vector2.ZERO
var bullet_pos = Vector2.ZERO

onready var dissapear_timer = $DissapearTimer
onready var turret_bullet_shape = $TurretBulletShape
onready var sprite = $Sprite
onready var player = get_parent().get_node("SuperSonic")

onready var line = $Line2D

func _ready():
	dissapear_timer.start()
	

func _physics_process(delta):
	move_and_slide(velocity*movement*delta)
	velocity = (player.position - position).normalized()
	
	


func _on_DissapearTimer_timeout():
	if not dissapear:
		dissapear_timer.stop()
		turret_bullet_shape.disabled = true
		sprite.visible = false
		queue_free()
		dissapear = true
		
		
	
