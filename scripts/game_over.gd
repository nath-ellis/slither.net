extends Node


func _on_play_again_pressed() -> void:
	"""
	Resets Manager.player_pos, Manager.player_vel and Manager.length and changes
	the scene back to game.tscn.
	"""
	
	Manager.player_pos = Vector2()
	Manager.player_vel = Vector2(Manager.player_speed, 0)
	Manager.length = 2
	
	get_tree().change_scene_to_file("res://scenes/game.tscn")
