extends Node2D


@onready var username = $UI/Username


func _on_play_pressed() -> void:
	"""
	Sets the player's in-game name using the LineEdit Username, or a random
	value if none is provided.
	Then seeds Godot's randomizer and changes the scene to game.tscn.
	"""
	
	# Set player name
	if username.text == "":
		Manager.player_name = Manager.new_name()
	else:
		Manager.player_name = username.text
	
	randomize()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
