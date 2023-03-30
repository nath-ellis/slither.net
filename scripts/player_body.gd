extends Area2D


# Contains all of the places the player turned at
var move_to = []

@onready var sprite = $Sprite2D


func check_pos() -> void:
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
	if len(move_to) > 0:
		check_pos()
		global_position = global_position + move_to[0]["vel"]
		
	else:
		global_position = global_position + Manager.player_vel


func _ready() -> void:
	var count = 0
	
	for b in get_parent().get_children():
		if b is Area2D:
			count += 1
	
	if count == 2:  # There are 2 at the start
		if name == "PlayerBody1":
			sprite.texture = load("res://assets/snakes/default/body_2.png")
			
	else:
		# Should alternate between sprites
		if count % 2 == 0:
			sprite.texture = load("res://assets/snakes/default/body_1.png")
			
		else:
			sprite.texture = load("res://assets/snakes/default/body_2.png")


func _physics_process(_delta) -> void:
	if len(move_to) > 0:
		check_pos()
