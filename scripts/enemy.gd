extends Node2D


const ENEMY_BODY = preload("res://scenes/enemy_body.tscn")
const BIT = preload("res://scenes/bit.tscn")

var vel = Vector2(Manager.player_speed, 0)
var moved = false
var sped_up = false
var increase_length_counter = 0
var lose_length_counter = 0
var dead = false

@onready var face = $EnemyFace
@onready var face_sprite = $EnemyFace/Sprite
@onready var body = $Body
@onready var movement_timer = $MovementTimer
@onready var bits = $"../../Bits"


func add_move_to() -> void:
	for b in body.get_children():
		# Don't add duplicates
		if !b.move_to.has({"x": face.global_position.x, "y": face.global_position.y, "vel": vel}):
			b.move_to.append({
				"x": face.global_position.x,
				"y": face.global_position.y,
				"vel": vel,
			})


func _ready() -> void:
	var rand_x = randi_range(-50, 50)
	var rand_y = randi_range(-50, 50)
	
	# Randomize position
	global_position = Vector2(
		Manager.player_pos.x + (rand_x * 64) + 32,
		Manager.player_pos.y + (rand_y * 64) + 32
	)
	
	for i in range(randi_range(0, 50)):
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
		var chance = randi_range(1, 500)
		
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
	if !dead:
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
		# Add remains where the enemy dies
		for b in body.get_children():
			var new_bit_1 = BIT.instantiate()
			var new_bit_2 = BIT.instantiate()
			
			bits.add_child(new_bit_1)
			bits.add_child(new_bit_2)
			
			new_bit_1.global_position = Vector2(
				b.global_position.x + randi_range(0, 64),
				b.global_position.y + randi_range(0, 64)
			)
			new_bit_2.global_position = Vector2(
				b.global_position.x + randi_range(0, 64),
				b.global_position.y + randi_range(0, 64)
			)
		
		queue_free()


func increase_length(increase_amount) -> void:
	increase_length_counter += increase_amount


func _on_enemy_face_area_entered(area) -> void:
	if area.name == "Face" or area.name == "EnemyFace":
		area.get_parent().call("die")


func die() -> void:
	face_sprite.texture = load("res://assets/snakes/default/dead.png")
	dead = true
