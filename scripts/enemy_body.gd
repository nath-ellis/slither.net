extends Area2D


# Contains all of the places the player turned at
var move_to = []
var colour = "default"

@onready var sprite = $Sprite2D


func _ready() -> void:
	"""
	Changes the sprite to either 'body_1.png' or 'body_2.png' based on 
	the body part's position in the enemy. (Should alternate.)
	"""
	
	var count = 0
	
	for b in get_parent().get_children():
		if b is Area2D:
			count += 1
	
	colour = get_parent().get_parent().colour
	
	if count == 2:  # There are 2 at the start
		if name == "EnemyBody1":
			sprite.texture = load("res://assets/snakes/" + colour + "/body_2.png")
		else:
			sprite.texture = load("res://assets/snakes/" + colour + "/body_1.png")
			
	else:
		# Should alternate between sprites
		if count % 2 == 0:
			sprite.texture = load("res://assets/snakes/" + colour + "/body_1.png")
			
		else:
			sprite.texture = load("res://assets/snakes/" + colour + "/body_2.png")


func _physics_process(_delta) -> void:
	"""
	Calls check_pos() if the length of move_to is greater than 0.
	"""
	
	if len(move_to) > 0:
		check_pos()


func _on_area_entered(area) -> void:
	"""
	Collision detection for the body of the enemy.
	"""
	
	if area.name == "Face" or area.name == "EnemyFace":
		area.get_parent().call("die")


func check_pos() -> void:
	"""
	Checks whether the body part has reached where move_to[0] says it should
	have, removing move_to[0] if this is the case.
	"""
	
	# Reached the destination
	if move_to[0]["vel"].x != 0:
		if move_to[0]["vel"].x > 0 and global_position.x >= move_to[0]["x"] or \
			move_to[0]["vel"].x < 0 and global_position.x <= move_to[0]["x"] :
			move_to.remove_at(0)
			
	elif move_to[0]["vel"].y != 0:
		if move_to[0]["vel"].y > 0 and global_position.y >= move_to[0]["y"] or \
			move_to[0]["vel"].y < 0 and global_position.y <= move_to[0]["y"]:
			move_to.remove_at(0)


func move() -> void:
	"""
	Moves the body part based on either move_to[0] or the regular Manager.player_vel
	(all snakes should be moving at the same speed regardless of whether or
	not they are a player).
	"""
	
	if len(move_to) > 0:
		check_pos()
		global_position = global_position + move_to[0]["vel"]
		
	else:
		global_position = global_position + get_parent().get_parent().vel
