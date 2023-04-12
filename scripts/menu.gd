extends Node2D


@onready var title_screen = $UI/TitleScreen
@onready var colour_screen = $UI/ColourScreen
@onready var username = $UI/TitleScreen/Username
@onready var snake_face = $UI/ColourScreen/Snake/Face
@onready var snake_body_1 = $UI/ColourScreen/Snake/Body1
@onready var snake_body_2 = $UI/ColourScreen/Snake/Body2
@onready var snake_body_3 = $UI/ColourScreen/Snake/Body3
@onready var highscore = $UI/TitleScreen/Highscore


func _ready() -> void:
	"""
	Calls Manager.load_data() and sets the text in the LineEdit to the username
	from the saved data, then sets the snake's sprites.
	"""
	
	Manager.load_data()
	username.text = Manager.saved_data["username"]
	highscore.text += str(Manager.saved_data["highscore"])
	
	# Load correct sprites
	snake_face.texture = load("res://assets/snakes/" + Manager.player_colour + "/face.png")
	snake_body_1.texture = load("res://assets/snakes/" + Manager.player_colour + "/body_2.png")
	snake_body_2.texture = load("res://assets/snakes/" + Manager.player_colour + "/body_1.png")
	snake_body_3.texture = load("res://assets/snakes/" + Manager.player_colour + "/body_2.png")


func _on_continue_pressed() -> void:
	"""
	Hides the title screen and shows the colour screen.
	"""
	
	title_screen.hide()
	colour_screen.show()


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


func _on_colour_btn_pressed(colour) -> void:
	"""
	Changes the preview snake's sprites and the player's.
	"""
	
	snake_face.texture = load("res://assets/snakes/" + colour + "/face.png")
	snake_body_1.texture = load("res://assets/snakes/" + colour + "/body_2.png")
	snake_body_2.texture = load("res://assets/snakes/" + colour + "/body_1.png")
	snake_body_3.texture = load("res://assets/snakes/" + colour + "/body_2.png")
	
	Manager.player_colour = colour
