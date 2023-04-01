extends Area2D


func _ready() -> void:
	global_position = Vector2(
		randi_range(Manager.player_pos.x - get_viewport_rect().size.x, Manager.player_pos.x + get_viewport_rect().size.x),
		randi_range(Manager.player_pos.y - get_viewport_rect().size.y, Manager.player_pos.y + get_viewport_rect().size.y)
	)


func _on_area_entered(area) -> void:
	Manager.length += 1
	
	if area.get_parent().has_method("increase_length"):
		if get_meta("size") == "large":
			area.get_parent().call_deferred("increase_length", 10)
		elif get_meta("size") == "small":
			area.get_parent().call_deferred("increase_length", 2)
	
	queue_free()
