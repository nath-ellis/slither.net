extends Node2D


const PLAYER_BODY = preload("res://scenes/player_body.tscn")

var moved = false
var sped_up = false
var increase_length_counter = 0
var lose_length_counter = 0
var dead = false

@onready var face = $Face
@onready var face_sprite = $Face/Sprite
@onready var body = $Body
@onready var movement_timer = $MovementTimer
@onready var username = $Face/Name


func _ready() -> void:
	"""
	Changes the player's in-game name to the one chosen on menu.tscn.
	"""
	
	username.text = Manager.player_name


func _process(_delta) -> void:
	"""
	Increases the player's length when needed.
	"""
	
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
		
		Manager.length += 1
		increase_length_counter -= 10


func _physics_process(_delta) -> void:
	"""
	Handles user input, changing the player's direction accordingly.
	"""
	
	# Prevent the player from changing direction too fast
	if !moved:
		if Input.is_action_pressed("up") and Manager.player_vel.y == 0:
			add_move_to()
			Manager.player_vel = Vector2(0, -Manager.player_speed)
			moved = true
			
		elif Input.is_action_pressed("down") and Manager.player_vel.y == 0:
			add_move_to()
			Manager.player_vel = Vector2(0, Manager.player_speed)
			moved = true
			
		elif Input.is_action_pressed("left") and Manager.player_vel.x == 0:
			add_move_to()
			Manager.player_vel = Vector2(-Manager.player_speed, 0)
			moved = true
			
		elif Input.is_action_pressed("right") and Manager.player_vel.x == 0:
			add_move_to()
			Manager.player_vel = Vector2(Manager.player_speed, 0)
			moved = true
	
	if Input.is_action_just_pressed("speed_up") and !sped_up and body.get_child_count() > 1:
		sped_up = true
	
	if Input.is_action_just_released("speed_up") and sped_up:
		sped_up = false


func _on_movement_timer_timeout() -> void:
	"""
	Moves the player once MovementTimer times out unless the player is 'dead'
	where it then changes the scene to game_over.tscn.
	"""
	
	if !dead:
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
				if Manager.length > 1:
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
		
		moved = false
	else:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_face_area_entered(area) -> void:
	"""
	Collision detection for the player's face.
	"""
	
	if area.name == "EnemyFace" and area.global_position == global_position:
		area.get_parent().call("die")


func add_move_to() -> void:
	"""
	Adds an item to the move_to array for all of the body pieces.
	"""
	
	for b in body.get_children():
		# Don't add duplicates
		if !b.move_to.has({"x": face.global_position.x, "y": face.global_position.y, "vel": Manager.player_vel}):
			b.move_to.append({
				"x": face.global_position.x,
				"y": face.global_position.y,
				"vel": Manager.player_vel,
			})


func increase_length(increase_amount) -> void:
	"""
	Called by the bit that the player collides with.
	Once it reaches a certain number the code in _process() increases the player's length.
	"""
	
	increase_length_counter += increase_amount


func die() -> void:
	"""
	Called by the enemy that the player collides with.
	Changes the face_sprite to the 'dead' version.
	"""
	
	face_sprite.texture = load("res://assets/snakes/default/dead.png")
	dead = true
