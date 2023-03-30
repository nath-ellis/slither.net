extends Node2D


const PLAYER_BODY = preload("res://scenes/player_body.tscn")

@onready var face = $Face
@onready var face_sprite = $Face/Sprite
@onready var body = $Body
@onready var movement_timer = $MovementTimer


func add_move_to() -> void:
	for b in body.get_children():
		# Don't add duplicates
		if !b.move_to.has({"x": face.global_position.x, "y": face.global_position.y, "vel": Manager.player_vel}):
			b.move_to.append({
				"x": face.global_position.x,
				"y": face.global_position.y,
				"vel": Manager.player_vel,
			})


func _physics_process(_delta) -> void:
	if Input.is_action_pressed("up") and Manager.player_vel.y == 0:
		add_move_to()
		Manager.player_vel = Vector2(0, -Manager.player_speed)
		
	elif Input.is_action_pressed("down") and Manager.player_vel.y == 0:
		add_move_to()
		Manager.player_vel = Vector2(0, Manager.player_speed)
		
	elif Input.is_action_pressed("left") and Manager.player_vel.x == 0:
		add_move_to()
		Manager.player_vel = Vector2(-Manager.player_speed, 0)
		
	elif Input.is_action_pressed("right") and Manager.player_vel.x == 0:
		add_move_to()
		Manager.player_vel = Vector2(Manager.player_speed, 0)


func _on_movement_timer_timeout() -> void:
	# Rotate sprite on movement to prevent glitchiness
	if Manager.player_vel.y < 0:
		face_sprite.rotation_degrees = 0
		
	elif Manager.player_vel.y > 0:
		face_sprite.rotation_degrees = 180
		
	elif Manager.player_vel.x < 0:
		face_sprite.rotation_degrees = 270
		
	elif Manager.player_vel.x > 0:
		face_sprite.rotation_degrees = 90
	
	face.global_position = face.global_position + Manager.player_vel
	
	for b in body.get_children():
		b.call("move")
	
	movement_timer.start()


func increase_length() -> void:
	var new_body = PLAYER_BODY.instantiate()
	var end_body = body.get_children()[len(body.get_children())-1]
	
	if len(end_body.move_to) > 0:
		new_body.position = end_body.position - end_body.move_to[0]["vel"]
		
		# Add places it needs to move to
		for e in end_body.move_to:
			new_body.move_to.append(e)
		
	else:
		new_body.position = end_body.position - Manager.player_vel
	
	body.add_child(new_body)
