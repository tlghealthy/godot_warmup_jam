extends CharacterBody2D

@export var gravity: float = 2000.0
@export var burst_size: int = 8
@export var cooldown: float = 2.0
@export var projectile_scene: PackedScene

var timer: float = 0.0

@onready var weapon: Node = $Weapon

func _ready() -> void:
	add_to_group("enemy")
	if weapon:
		weapon.set("projectile_scene", projectile_scene)
		weapon.set("fire_rate", 9999.0) # we'll gate bursts manually
		weapon.set("target_groups", [])
		weapon.set("ignore_groups", [StringName("enemy")])
		weapon.set("bullet_color", Color(0.7, 0.5, 1.0, 1))

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		_fire_burst()
		timer = cooldown

func _fire_burst() -> void:
	if not weapon:
		return
	var dirs: int = max(1, burst_size)
	for i in range(dirs):
		var angle := TAU * float(i) / float(dirs)
		weapon.fire(Vector2.RIGHT.rotated(angle))

