extends Node2D


const PLAYER_BODY = preload("res://scenes/player_body.tscn")

var sped_up = false
var increase_length_counter = 0
var lose_length_counter = 0

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


func _process(_delta) -> void:
	# Check whether the player's size should be increased
	if increase_length_counter >= 10:
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
		
		increase_length_counter -= 10

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
	
	if Input.is_action_just_pressed("speed_up") and !sped_up and body.get_child_count() > 1:
		sped_up = true
	
	if Input.is_action_just_released("speed_up") and sped_up:
		sped_up = false


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
	Manager.player_pos = face.global_position
	
	for b in body.get_children():
		b.call("move")
	
	if sped_up:
		# Decrease length when sped up
		if lose_length_counter >= 5:
			Manager.length -= 1
			
			if body.get_child_count() > 1:
				body.get_children()[len(body.get_children())-1].queue_free()
				
			else:
				sped_up = false
			
			lose_length_counter = 0
		
		movement_timer.start(0.1)
		lose_length_counter += 1
		
	else:
		movement_timer.start(0.25)


func increase_length(increase_amount) -> void:
	increase_length_counter += increase_amount
