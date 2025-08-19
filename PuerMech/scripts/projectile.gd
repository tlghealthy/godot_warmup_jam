extends Area2D

@export var speed: float = 800.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0
@export var damage: int = 10
@export var collision_mask_names: Array[StringName] = []

var time_alive: float = 0.0

func _ready() -> void:
	if direction.length() == 0:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	if collision_mask_names.size() > 0:
		var mask := 0
		for name in collision_mask_names:
			mask |= 1 << int(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + name, 0))
		collision_mask = mask
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_node("Health"):
		var h := body.get_node("Health")
		if h and h.has_method("apply_damage"):
			h.apply_damage(damage)
	queue_free()

