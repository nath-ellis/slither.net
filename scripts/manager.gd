extends Node


var player_speed = 64
var player_vel = Vector2(player_speed, 0)
var player_pos = Vector2()
var length = 0


func increase_length() -> void:
	length += 1
