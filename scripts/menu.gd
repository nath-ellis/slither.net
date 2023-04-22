extends Node2D


@onready var ui = $UI
@onready var how_to_play = $UI/HowToPlay
@onready var title_screen = $UI/TitleScreen
@onready var colour_screen = $UI/ColourScreen
@onready var username = $UI/TitleScreen/Username
@onready var snake = $UI/ColourScreen/Snake
@onready var snake_face = $UI/ColourScreen/Snake/Face
@onready var snake_body_1 = $UI/ColourScreen/Snake/Body1
@onready var snake_body_2 = $UI/ColourScreen/Snake/Body2
@onready var snake_body_3 = $UI/ColourScreen/Snake/Body3
@onready var highscore = $UI/TitleScreen/Highscore
@onready var show_touch_controls_btn = $UI/TitleScreen/ShowTouchControls


func _ready() -> void:
	"""
	Calls Manager.load_data() and sets the text in the LineEdit to the username
	from the saved data, then shows the HowToPlay menu if needed, then sets the 
	snake's sprites and shows touchscreen controls if needed, hiding the toggle 
	on phones.
	"""
	
	Manager.load_data()
	username.text = Manager.saved_data["username"]
	highscore.text += str(Manager.saved_data["highscore"])
	
	# Resize controls so that UI is centred
	how_to_play.size = get_viewport_rect().size
	title_screen.size = get_viewport_rect().size
	colour_screen.size = get_viewport_rect().size
	
	if Manager.show_how_to_play:
		title_screen.hide()
		how_to_play.show()
	
	# Load correct sprites
	snake_face.texture = load("res://assets/snakes/" + Manager.player_colour + "/face.png")
	snake_body_1.texture = load("res://assets/snakes/" + Manager.player_colour + "/body_2.png")
	snake_body_2.texture = load("res://assets/snakes/" + Manager.player_colour + "/body_1.png")
	snake_body_3.texture = load("res://assets/snakes/" + Manager.player_colour + "/body_2.png")
	
	# Enable toggle
	if Manager.show_touchscreen_controls:
		show_touch_controls_btn.button_pressed = true
	
	# Hide toggle on phones as the touch controls are necessary
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		show_touch_controls_btn.hide()
	
	# Centres the snake
	while snake.position.x < (get_viewport_rect().size.x / 2) + 64:
		snake.position.x += 64


func _process(_delta) -> void:
	"""
	Moves the UI to above the virtual keyboard if needed.
	"""
	
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		if DisplayServer.virtual_keyboard_get_height() != 0:
			ui.position.y = -200
		else:
			ui.position.y = 0


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


func _on_show_touch_controls_toggled(button_pressed) -> void:
	"""
	Enables/disables touch controls
	"""
	
	Manager.show_touchscreen_controls = button_pressed


func _on_done_how_to_play_pressed() -> void:
	"""
	Changes from HowToPlay to the TitleScreen
	"""
	
	how_to_play.hide()
	title_screen.show()
