extends Node2D


const BIT = preload("res://scenes/bit.tscn")
const LARGE_BIT = preload("res://scenes/large_bit.tscn")

@onready var player = $Player
@onready var bits = $Bits
@onready var bit_timer = $BitTimer
@onready var growth_progress_bar = $UI/GrowthProgressBar
@onready var growth_particles = $UI/GrowthParticles


func _process(delta) -> void:
	if growth_progress_bar.value != growth_progress_bar.max_value:
		growth_progress_bar.value = player.increase_length_counter * 10
	else:
		# Reset bar after particles finish
		if !growth_particles.emitting:
			growth_progress_bar.value = player.increase_length_counter * 10


func _on_bit_timer_timeout() -> void:
	var chance = randi_range(0, 15)
	
	if chance == 1:
		bits.add_child(BIT.instantiate())
	else:
		chance = randi_range(0, 30)
		
		if chance == 1:
			bits.add_child(LARGE_BIT.instantiate())
	
	bit_timer.start()


func _on_growth_progress_bar_value_changed(value):
	if value == growth_progress_bar.max_value:
		# Emit particles
		growth_particles.emitting = true
