extends Node

@export var weapon: Node

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("PlayerShoot") and weapon and weapon.has_method("can_fire"):
		if weapon.can_fire():
			var dir: Vector2 = Vector2.RIGHT
			var owner2d: Node2D = owner as Node2D
			if owner2d:
				var mouse_pos: Vector2 = owner2d.get_global_mouse_position()
				dir = (mouse_pos - owner2d.global_position).normalized()
			weapon.fire(dir)
