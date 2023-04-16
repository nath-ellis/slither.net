extends Node2D


const BIT = preload("res://scenes/bit.tscn")
const LARGE_BIT = preload("res://scenes/large_bit.tscn")
const ENEMY = preload("res://scenes/enemy.tscn")

var leaderboad_content = [
	["name", 10],
	["name", 8],
	["name", 6],
	["name", 5],
	["name", 4],
]

@onready var player = $Player
@onready var bits = $Bits
@onready var bit_timer = $BitTimer
@onready var ui_control = $UI/Control
@onready var growth_progress_bar = $UI/Control/GrowthProgressBar
@onready var growth_particles = $UI/Control/GrowthParticles
@onready var length = $UI/Control/Length
@onready var enemies = $Enemies
@onready var enemy_timer = $EnemyTimer
@onready var leaderboard = $UI/Control/Leaderboard
@onready var leaderboad_labels = [
	$UI/Control/Leaderboard/First,
	$UI/Control/Leaderboard/Second,
	$UI/Control/Leaderboard/Third,
	$UI/Control/Leaderboard/Fourth,
	$UI/Control/Leaderboard/Fifth,
]
@onready var touch_controls = $UI/Control/TouchControls
@onready var speed_up_btn = $UI/Control/TouchControls/SpeedUp


func _ready() -> void:
	"""
	Calls Manager.save_data() and shows touchscreen controls if needed.
	"""
	
	Manager.length = 2
	Manager.save_data()
	
	# Resize controls
	ui_control.size = get_viewport_rect().size
	
	speed_up_btn.position.x = get_viewport_rect().size.x - 170
	
	if Manager.show_touchscreen_controls:
		for t in touch_controls.get_children():
			t.show()

func _process(_delta) -> void:
	"""
	Changes the progress bar based on how close the player is to growing
	and set the number on-screen to the player's length.
	Also, calls update_leaderboard().
	"""
	
	if growth_progress_bar.value != growth_progress_bar.max_value:
		growth_progress_bar.value = player.increase_length_counter * 10
	else:
		# Reset bar after particles finish
		if !growth_particles.emitting:
			growth_progress_bar.value = player.increase_length_counter * 10
	
	length.text = str(Manager.length)
	
	update_leaderboard()


func _on_bit_timer_timeout() -> void:
	"""
	Creates new bits once BitTimer times out.
	"""
	
	var chance = randi_range(0, 15)
	
	if chance == 1:
		bits.add_child(BIT.instantiate())
	else:
		chance = randi_range(0, 30)
		
		if chance == 1:
			bits.add_child(LARGE_BIT.instantiate())
	
	bit_timer.start()


func _on_growth_progress_bar_value_changed(value) -> void:
	"""
	Emits particles from the progress bar if it is full.
	"""
	
	if value == growth_progress_bar.max_value:
		# Emit particles
		growth_particles.emitting = true


func _on_enemy_timer_timeout() -> void:
	"""
	Adds new enemies once EnemyTimer times out.
	"""
	
	enemies.add_child(ENEMY.instantiate())
	enemy_timer.start()


func update_leaderboard() -> void:
	"""
	Updates the leaderboard.
	It does this by removing the previous values, then looping through all
	enemies and if the length is large enough adding them to the leaderboard.
	Finally, it checks whether the player should be added to the leaderboard,
	removes data past index 4 and updates the labels on-screen.
	"""
	
	# Add filler data so that next code can run
	leaderboad_content = [
		["name", 1],
		["name", 1],
		["name", 1],
		["name", 1],
		["name", 1],
	]
	
	# Add correct data to the leaderboad
	for e in enemies.get_children():
		var insert_at = -1
		
		if e.length >= leaderboad_content[0][1]:
			insert_at = 0
		elif e.length >= leaderboad_content[1][1]:
			insert_at = 1
		elif e.length >= leaderboad_content[2][1]:
			insert_at = 2
		elif e.length >= leaderboad_content[3][1]:
			insert_at = 3
		elif e.length >= leaderboad_content[4][1]:
			insert_at = 4
		
		if insert_at != -1:
			leaderboad_content.insert(insert_at, [e.username.text, e.length])
	
	# Add player if needed
	var insert_at = -1
	
	if Manager.length >= leaderboad_content[0][1]:
		insert_at = 0
	elif Manager.length >= leaderboad_content[1][1]:
		insert_at = 1
	elif Manager.length >= leaderboad_content[2][1]:
		insert_at = 2
	elif Manager.length >= leaderboad_content[3][1]:
		insert_at = 3
	elif Manager.length >= leaderboad_content[4][1]:
		insert_at = 4
	
	if insert_at != -1:
		leaderboad_content.insert(insert_at, [Manager.player_name, Manager.length])
	
	# Remove data past index 4
	while len(leaderboad_content) > 5:
		leaderboad_content.remove_at(5)
	
	for i in range(5):
		leaderboad_labels[i].text = leaderboad_content[i][0] + ": " + str(leaderboad_content[i][1])
