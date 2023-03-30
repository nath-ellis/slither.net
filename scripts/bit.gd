extends Area2D


func _on_area_entered(area) -> void:
	Manager.increase_length()
	area.get_parent().call_deferred("increase_length")
	queue_free()
