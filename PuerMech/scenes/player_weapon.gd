extends Node

@onready var weapon: Node = $"../Weapon"
#@export var weapon: Node

func _ready() -> void:
	set_physics_process(true)
	print_debug("WeaponController ready; weapon found? ", weapon != null)

func _physics_process(_delta: float) -> void:
	var shooting := Input.is_action_pressed("PlayerShoot")
	if shooting and weapon and weapon.has_method("can_fire"):
		var can : bool = weapon.can_fire()
		print_debug("PlayerShoot pressed; can_fire=", can)
		if can:
			var dir: Vector2 = Vector2.RIGHT
			var owner2d: Node2D = get_parent() as Node2D
			if owner2d:
				var mouse_pos: Vector2 = owner2d.get_global_mouse_position()
				dir = (mouse_pos - owner2d.global_position).normalized()
			weapon.fire(dir)
