extends Node

@export var weapon: Node

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("PlayerShoot") and weapon and weapon.has_method("can_fire"):
		if weapon.can_fire():
			var dir := Vector2.RIGHT
			if owner is Node2D:
				var mouse_pos := owner.get_global_mouse_position()
				dir = (mouse_pos - (owner as Node2D).global_position).normalized()
			weapon.fire(dir)
