extends Node


var player_speed = 64
var player_vel = Vector2(player_speed, 0)
var player_pos = Vector2()
var length = 2
var nouns = []
var adjectives = []


func load_names() -> void:
	var nouns_file = FileAccess.open("res://assets/nouns.txt", FileAccess.READ)
	
	# Loops through the file
	while not nouns_file.eof_reached():
		nouns.append(nouns_file.get_line())
	
	var adjectives_file = FileAccess.open("res://assets/adjectives.txt", FileAccess.READ)
	
	while not adjectives_file.eof_reached():
		adjectives.append(adjectives_file.get_line())


func new_name() -> String:
	if nouns.size() == 0 or adjectives.size() == 0:
		load_names()
	
	var word_1
	var word_2
	
	match randi_range(1, 2):
		1:
			word_1 = nouns[randi() % nouns.size()]
			word_2 = nouns[randi() % nouns.size()]
		2:
			word_1 = adjectives[randi() % adjectives.size()].capitalize()
			word_2 = nouns[randi() % nouns.size()]
	
	match randi_range(1, 3):
		1:
			return word_1 + word_2
		2:
			return word_1
		_:
			return word_2
