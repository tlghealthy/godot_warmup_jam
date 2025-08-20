extends CharacterBody2D

@export var gravity: float = 2000.0
@export var move_speed: float = 80.0
@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.8

@onready var weapon: Node = $Weapon

func _ready() -> void:
	add_to_group("enemy")
	if weapon:
		weapon.set("projectile_scene", projectile_scene)
		weapon.set("fire_rate", fire_rate)
		weapon.set("target_groups", [StringName("player")])
		weapon.set("ignore_groups", [StringName("enemy")])
		weapon.set("bullet_color", Color(1.0, 0.8, 0.2, 1))

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = move_speed
	move_and_slide()

func _process(delta: float) -> void:
	# Fire a 5-way spread, rotating slowly over time
	if not weapon or not weapon.has_method("can_fire"):
		return
	if weapon.can_fire():
		var base := (Vector2.RIGHT).rotated(Time.get_ticks_msec() / 1000.0)
		var steps := [-0.5, -0.25, 0, 0.25, 0.5]
		for s in steps:
			weapon.fire(base.rotated(s))

