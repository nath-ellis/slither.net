extends CharacterBody2D


var speed = 200
var vel = Vector2(speed, 0)


func _physics_process(delta) -> void:
	if Input.is_action_pressed("up"):
		vel = Vector2(0, -speed)
		
	elif Input.is_action_pressed("down"):
		vel = Vector2(0, speed)
		
	elif Input.is_action_pressed("left"):
		vel = Vector2(-speed, 0)
		
	elif Input.is_action_pressed("right"):
		vel = Vector2(speed, 0)
	
	move_and_collide(vel * delta)
