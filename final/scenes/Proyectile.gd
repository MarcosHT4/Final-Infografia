extends KinematicBody2D

var speed = 10
var movement = 25
var velocity = Vector2.ZERO 

onready var meteor_sprite = get_child(0)
onready var meteor_shape = get_child(1)

func _physics_process(delta):
	velocity.x -= movement
	move_and_slide(velocity*speed*delta)
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		var body = collision.collider
		if body.name == "Limit3":
			meteor_sprite.visible = false
			meteor_shape.disabled = true
			
	
