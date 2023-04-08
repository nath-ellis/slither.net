extends Node2D


@onready var username = $UI/Username


func _on_play_pressed() -> void:
	# Set player name
	if username.text == "":
		Manager.player_name = Manager.new_name()
	else:
		Manager.player_name = username.text
	
	randomize()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
