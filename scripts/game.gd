extends Node2D


const BIT = preload("res://scenes/bit.tscn")
const LARGE_BIT = preload("res://scenes/large_bit.tscn")

@onready var player = $Player
@onready var bits = $Bits
@onready var bit_timer = $BitTimer


func _on_bit_timer_timeout() -> void:
	var chance = randi_range(0, 15)
	
	if chance == 1:
		bits.add_child(BIT.instantiate())
	else:
		chance = randi_range(0, 30)
		
		if chance == 1:
			bits.add_child(LARGE_BIT.instantiate())
	
	bit_timer.start()
