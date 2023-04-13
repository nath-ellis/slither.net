extends Area2D


@onready var sprite = $Sprite2D
@onready var timer = $Timer


func _ready() -> void:
	"""
	Randomizes the bit's position based on the player's position.
	Then sets the time that the bit will be in the game for.
	Finally, randomizes the sprite.
	"""
	
	global_position = Vector2(
		randi_range(Manager.player_pos.x - get_viewport_rect().size.x, Manager.player_pos.x + get_viewport_rect().size.x),
		randi_range(Manager.player_pos.y - get_viewport_rect().size.y, Manager.player_pos.y + get_viewport_rect().size.y)
	)
	
	# Time that the bit will be in the game for
	timer.wait_time = randf_range(10.0, 100.0)
	timer.start()
	
	if get_meta("size") == "large":
		match randi_range(1, 7):
			1:
				sprite.texture = load("res://assets/bits/large_blue.png")
			2:
				sprite.texture = load("res://assets/bits/large_green.png")
			3:
				sprite.texture = load("res://assets/bits/large_light_blue.png")
			4:
				sprite.texture = load("res://assets/bits/large_lime.png")
			5:
				sprite.texture = load("res://assets/bits/large_orange.png")
			6:
				sprite.texture = load("res://assets/bits/large_white.png")
			7:
				sprite.texture = load("res://assets/bits/large_yellow.png")
				
	elif get_meta("size") == "small":
		match randi_range(1, 7):
			1:
				sprite.texture = load("res://assets/bits/blue.png")
			2:
				sprite.texture = load("res://assets/bits/green.png")
			3:
				sprite.texture = load("res://assets/bits/light_blue.png")
			4:
				sprite.texture = load("res://assets/bits/lime.png")
			5:
				sprite.texture = load("res://assets/bits/orange.png")
			6:
				sprite.texture = load("res://assets/bits/white.png")
			7:
				sprite.texture = load("res://assets/bits/yellow.png")


func _on_area_entered(area) -> void:
	"""
	Collision detection for the bit.
	Calls increase_length() along with how much it should increase by.
	Removes the bit after the collision.
	"""
	
	if area.get_parent().has_method("increase_length"):
		if get_meta("size") == "large":
			area.get_parent().call_deferred("increase_length", 5)
			
		elif get_meta("size") == "small":
			area.get_parent().call_deferred("increase_length", 2)
	
	queue_free()


func _on_timer_timeout() -> void:
	"""
	Removes the bit after the timer times out.
	"""
	
	queue_free()
