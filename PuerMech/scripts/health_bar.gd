extends Node2D

@export var health_path: NodePath
@export var bar_width: int = 80
@export var bar_height: int = 8
@export var show_when_full: bool = false

var health: Node
var current: int = 0
var max_value: int = 1

func _ready() -> void:
	if health_path != NodePath():
		health = get_node(health_path)
		if health:
			health.changed.connect(_on_health_changed)
			if health.has_method("current_health"):
				# Not needed; we track via signal
				pass
	queue_redraw()

func _on_health_changed(cur: int, mx: int) -> void:
	current = cur
	max_value = mx
	queue_redraw()

func _draw() -> void:
	if not show_when_full and current >= max_value:
		return
	var percent := 0.0 if max_value <= 0 else float(current) / float(max_value)
	var bg := Color(0,0,0,0.7)
	var fg := Color(0.9,0.2,0.2,1.0)
	var outline := Color(1,1,1,0.8)
	var rect := Rect2(Vector2(-bar_width/2, -48), Vector2(bar_width, bar_height))
	draw_rect(rect.grow(1), outline, false, 2)
	draw_rect(rect, bg)
	var filled := Rect2(rect.position, Vector2(bar_width * percent, bar_height))
	draw_rect(filled, fg)
