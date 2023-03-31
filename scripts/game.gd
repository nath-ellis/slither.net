extends Node2D


const BIT = preload("res://scenes/bit.tscn")

@onready var player = $Player
@onready var bits = $Bits
@onready var bit_timer = $BitTimer


func _on_bit_timer_timeout() -> void:
	var chance = randi_range(0, 15)
	
	if chance == 1:
		var new_bit = BIT.instantiate()
		bits.add_child(new_bit)
	
	bit_timer.start()
