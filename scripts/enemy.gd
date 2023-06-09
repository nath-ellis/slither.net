extends Node2D


const ENEMY_BODY = preload("res://scenes/enemy_body.tscn")
const BIT = preload("res://scenes/bit.tscn")
const LARGE_BIT = preload("res://scenes/large_bit.tscn")

var vel = Vector2(Manager.player_speed, 0)
var moved = false
var sped_up = false
var increase_length_counter = 0
var lose_length_counter = 0
var dead = false
var colour_options = [
	"black",
	"blue",
	"blueandyellow",
	"cyan",
	"default",
	"greenandblack",
	"greenandpink",
	"grey",
	"purple",
	"red",
	"redandorange",
	"redandyellow",
	"teal",
	"white"
]
var colour = colour_options[randi() % colour_options.size()]
var length = 2

@onready var face = $EnemyFace
@onready var face_sprite = $EnemyFace/Sprite
@onready var body = $Body
@onready var movement_timer = $MovementTimer
@onready var bits = $"../../Bits"
@onready var username = $EnemyFace/Name


func _ready() -> void:
	"""
	Loads the correct face sprite based on the random colour.
	Then sets a random position, taking the player's position into account
	to prevent situations that the player cannot react to. (ie: enemy spawns
	on top of player, causing them to die.)
	After that, it sets a random length, adding the correct amount of body
	parts while making sure not to intrude on the player's position.
	Finally, it sets a random in-game name for the enemy. 
	"""
	
	face_sprite.texture = load("res://assets/snakes/" + colour + "/face.png")
	
	# Set position
	var rand_x = randi_range(-100, 100)
	var rand_y = randi_range(-100, 100)
	
	# Randomize position
	global_position = Vector2(
		(rand_x * 64) + 32,
		(rand_y * 64) + 32
	)
	
	# The radius around the player where no enemies should spawn
	var radius = 5
	
	# Move if too close to player
	if global_position.x < Manager.player_pos.x + (64 * radius) and \
		global_position.x > Manager.player_pos.x - (64 * radius):
			if global_position.x < Manager.player_pos.x:
				global_position.y -= (64 * radius)
			else:
				global_position.y += (64 * radius)
	
	if global_position.y < Manager.player_pos.y + (64 * radius) and \
		global_position.y > Manager.player_pos.y - (64 * radius):
			if global_position.y < Manager.player_pos.x:
				global_position.x -= (64 * radius)
			else:
				global_position.x += (64 * radius)
	
	# Prevent enemies from spawning on the same Y level to prevent the body from extending into the player
	if global_position.y == Manager.player_pos.y:
		global_position.y += 64
	
	# Add body
	for i in range(randi_range(0, 100)):
		var new_body = ENEMY_BODY.instantiate()
		var end_body = body.get_children()[len(body.get_children())-1]
		
		if len(end_body.move_to) > 0:
			new_body.position = end_body.position - end_body.move_to[0]["vel"]
			
			# Add places it needs to move to
			for e in end_body.move_to:
				new_body.move_to.append(e)
			
		else:
			new_body.position = end_body.position - vel
		
		# Stop adding body if too close to player to prevent it spawning on them
		if (global_position.x < Manager.player_pos.x + (64 * radius) and \
			global_position.x > Manager.player_pos.x - (64 * radius)) or \
			(global_position.y < Manager.player_pos.y + (64 * radius) and \
			global_position.y > Manager.player_pos.y - (64 * radius)):
				break
		
		body.add_child(new_body)
		length += 1
	
	username.text = Manager.new_name()


func _process(_delta) -> void:
	"""
	Increases the enemies' length when needed.
	"""
	
	# Check whether the enmemies' size should be increased
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
		
		length += 1
		increase_length_counter -= 10


func _physics_process(_delta) -> void:
	"""
	Randomizes the enemies direction and changes it accordingly.
	"""
	
	# Prevent the enemy from changing direction too fast
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
	"""
	Moves the enemy once MovementTimer times out unless the enemy is 'dead'
	where it then removes the enemy, adding bits as remains.
	"""
	
	if !dead:
		# Rotate sprite on movement to prevent glitchiness
		if vel.y < 0:
			face_sprite.rotation_degrees = 180
			
		elif vel.y > 0:
			face_sprite.rotation_degrees = 0
			
		elif vel.x < 0:
			face_sprite.rotation_degrees = 90
			
		elif vel.x > 0:
			face_sprite.rotation_degrees = 270
		
		face.global_position = face.global_position + vel
		
		for b in body.get_children():
			b.call("move")
		
		if sped_up:
			# Decrease length when sped up
			if length > 1:
				length -= 1
			
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
			var new_large_bit = LARGE_BIT.instantiate()
			
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
			
			# 1 in 10 chance for a large bit to be dropped
			if randi_range(1, 10) == 1:
				bits.add_child(new_large_bit)
				
				new_large_bit.global_position = Vector2(
					b.global_position.x + randi_range(0, 64),
					b.global_position.y + randi_range(0, 64)
				)
		
		queue_free()


func _on_enemy_face_area_entered(area) -> void:
	"""
	Collision detection for the enemies' face.
	"""
	
	if area.name == "Face" or area.name == "EnemyFace":
		area.get_parent().call("die")


func add_move_to() -> void:
	"""
	Adds an item to the move_to array for all of the body pieces.
	"""
	
	for b in body.get_children():
		# Don't add duplicates
		if !b.move_to.has({"x": face.global_position.x, "y": face.global_position.y, "vel": vel}):
			b.move_to.append({
				"x": face.global_position.x,
				"y": face.global_position.y,
				"vel": vel,
			})


func increase_length(increase_amount) -> void:
	"""
	Called by the enemy that the player collides with.
	Once it reaches a certain number the code in _process() increases the enemies' length.
	"""
	
	increase_length_counter += increase_amount


func die() -> void:
	"""
	Called by the enemy or player that this enemy collides with.
	Changes the face_sprite to the 'dead' version.
	"""
	
	face_sprite.texture = load("res://assets/snakes/" + colour + "/dead.png")
	dead = true
