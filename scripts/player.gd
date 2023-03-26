extends CharacterBody2D


var speed = 200
var vel = Vector2(speed, 0)

@onready var face = $Face


func _physics_process(delta) -> void:
	if Input.is_action_pressed("up"):
		vel = Vector2(0, -speed)
		face.rotation_degrees = 0
		
	elif Input.is_action_pressed("down"):
		vel = Vector2(0, speed)
		face.rotation_degrees = 180
		
	elif Input.is_action_pressed("left"):
		vel = Vector2(-speed, 0)
		face.rotation_degrees = 270
		
	elif Input.is_action_pressed("right"):
		vel = Vector2(speed, 0)
		face.rotation_degrees = 90
	
	move_and_collide(vel * delta)
