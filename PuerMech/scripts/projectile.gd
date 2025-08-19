extends Area2D

@export var speed: float = 800.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0
@export var damage: int = 10
@export var target_groups: Array[StringName] = []
@export var ignore_groups: Array[StringName] = []

var time_alive: float = 0.0

func _ready() -> void:
	if direction.length() == 0:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	global_position += direction * speed * _delta
	time_alive += _delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	for g in ignore_groups:
		if body.is_in_group(g):
			return
	if target_groups.size() > 0:
		var ok := false
		for g2 in target_groups:
			if body.is_in_group(g2):
				ok = true
				break
		if not ok:
			return
	if body.has_node("Health"):
		var h := body.get_node("Health")
		if h and h.has_method("apply_damage"):
			h.apply_damage(damage)
	queue_free()
