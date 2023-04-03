extends Node2D


const ENEMY_BODY = preload("res://scenes/enemy_body.tscn")

var vel = Vector2(Manager.player_speed, 0)
var moved = false
var sped_up = false
var increase_length_counter = 0
var lose_length_counter = 0

@onready var face = $EnemyFace
@onready var face_sprite = $EnemyFace/Sprite
@onready var body = $Body
@onready var movement_timer = $MovementTimer


func add_move_to() -> void:
	for b in body.get_children():
		# Don't add duplicates
		if !b.move_to.has({"x": face.global_position.x, "y": face.global_position.y, "vel": vel}):
			b.move_to.append({
				"x": face.global_position.x,
				"y": face.global_position.y,
				"vel": vel,
			})


func _process(_delta) -> void:
	# Check whether the player's size should be increased
	if increase_length_counter >= 10:
		var new_body = ENEMY_BODY.instantiate()
		var end_body = body.get_children()[len(body.get_children())-1]
		
		if len(end_body.move_to) > 0:
			new_body.position = end_body.position - end_body.move_to[0]["vel"]
			
			# Add places it needs to move to
			for e in end_body.move_to:
				new_body.move_to.append(e)
			
		else:
			new_body.position = end_body.position - vel
		
		body.add_child(new_body)
		
		increase_length_counter -= 10


func _physics_process(_delta) -> void:
	# Prevent the player from changing direction too fast
	if !moved:
		var chance = randi_range(1, 100)
		
		if chance == 1 and vel.y == 0:
			add_move_to()
			vel = Vector2(0, -Manager.player_speed)
			moved = true
			
		elif chance == 2 and vel.y == 0:
			add_move_to()
			vel = Vector2(0, Manager.player_speed)
			moved = true
			
		elif chance == 3 and vel.x == 0:
			add_move_to()
			vel = Vector2(-Manager.player_speed, 0)
			moved = true
			
		elif chance == 4 and vel.x == 0:
			add_move_to()
			vel = Vector2(Manager.player_speed, 0)
			moved = true
	
	var chance = randi_range(1, 100)
	
	if chance == 1 and !sped_up and body.get_child_count() > 1:
		sped_up = true
	
	if chance % 8 == 0 and sped_up:
		sped_up = false


func _on_movement_timer_timeout() -> void:
	# Rotate sprite on movement to prevent glitchiness
	if vel.y < 0:
		face_sprite.rotation_degrees = 0
		
	elif vel.y > 0:
		face_sprite.rotation_degrees = 180
		
	elif vel.x < 0:
		face_sprite.rotation_degrees = 270
		
	elif vel.x > 0:
		face_sprite.rotation_degrees = 90
	
	face.global_position = face.global_position + vel
	
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


func increase_length(increase_amount) -> void:
	increase_length_counter += increase_amount


func _on_enemy_face_area_entered(area):
	if area.name == "Face":
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	
	if area.name == "EnemyFace":
		area.get_parent().queue_free()
