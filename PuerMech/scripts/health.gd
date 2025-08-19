extends Node

signal changed(current: int, max: int)
signal damaged(amount: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health
	changed.emit(current_health, max_health)

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return
	current_health = max(0, current_health - amount)
	damaged.emit(amount)
	changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	if amount <= 0:
		return
	current_health = min(max_health, current_health + amount)
	changed.emit(current_health, max_health)

func set_max_health(new_max: int, fill_to_max: bool = true) -> void:
	max_health = max(1, new_max)
	if fill_to_max:
		current_health = max_health
	else:
		current_health = min(current_health, max_health)
	changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

