extends Node2D


@onready var ui = $UI
@onready var length_label = $UI/Length
@onready var snake = $UI/Snake
@onready var face = $UI/Snake/Face
@onready var body_1 = $UI/Snake/Body1


func _ready() -> void:
	"""
	Adds the length that the player reached to the label.
	Then changes sprites and length of the snake.
	Finally, calls Manager.save_data().
	"""
	
	ui.size = get_viewport_rect().size
	
	length_label.text += str(Manager.length)
	
	var body_1_sprite = load("res://assets/snakes/" + Manager.player_colour + "/body_1.png")
	var body_2_sprite = load("res://assets/snakes/" + Manager.player_colour + "/body_2.png")
	
	face.texture = load("res://assets/snakes/" + Manager.player_colour + "/dead.png")
	body_1.texture = body_2_sprite
	
	for i in range(Manager.length - 1):
		var new_body = Sprite2D.new()
		
		# Alternates the sprites
		if i % 2 == 0 or i == 0:
			new_body.texture = body_1_sprite
			
			if snake.position.x < get_viewport_rect().size.x:
				snake.position.x += 64  # Ensures snake is centred
		else:
			new_body.texture = body_2_sprite
		
		new_body.position = snake.get_children()[len(snake.get_children())-1].position
		new_body.position.x -= 64
		
		snake.add_child(new_body)
	
	Manager.save_data()


func _on_play_again_pressed() -> void:
	"""
	Changes the scene back to game.tscn.
	"""
	
	reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu_pressed():
	"""
	Changes the scene to menu.tscn.
	"""
	
	reset()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func reset() -> void:
	"""
	Resets Manager.player_pos, Manager.player_vel and Manager.length.
	"""
	
	Manager.player_pos = Vector2()
	Manager.player_vel = Vector2(Manager.player_speed, 0)
	Manager.length = 2
