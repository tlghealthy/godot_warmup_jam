extends Node

@export var projectile_scene: PackedScene
@export var fire_rate: float = 6.0 # shots per second
@export var muzzle_paths: Array[NodePath] = []
@export var bullet_speed: float = 900.0
@export var bullet_damage: int = 4
@export var bullet_radius: float = 6.0
@export var bullet_color: Color = Color(0.3, 0.7, 1.0, 1)
@export var target_groups: Array[StringName] = []
@export var ignore_groups: Array[StringName] = []

var _cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta

func can_fire() -> bool:
	return _cooldown <= 0.0 and projectile_scene != null

func fire(direction: Vector2) -> void:
	if not can_fire():
		return
	_cooldown = 1.0 / max(0.001, fire_rate)
	var muzzles: Array[Node2D] = []
	for p in muzzle_paths:
		var n: Node2D = get_node_or_null(p) as Node2D
		if n:
			muzzles.append(n)
	if muzzles.size() == 0:
		muzzles.append(owner as Node2D)
	for m in muzzles:
		var b = projectile_scene.instantiate()
		if b is Node2D:
			b.global_position = m.global_position
			b.set("direction", direction.normalized())
			b.set("speed", bullet_speed)
			b.set("damage", bullet_damage)
			b.set("radius", bullet_radius)
			b.set("color", bullet_color)
			b.set("target_groups", target_groups)
			b.set("ignore_groups", ignore_groups)
		# Add to the current scene root (not as a child of the shooter)
		get_tree().current_scene.add_child(b)

