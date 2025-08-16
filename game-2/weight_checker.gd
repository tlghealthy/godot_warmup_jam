extends RigidBody2D

signal weight_fell_off_screen(weight_node)

var viewport_size: Vector2
var check_timer: Timer

func _ready():
	viewport_size = get_viewport().get_visible_rect().size
	
	check_timer = Timer.new()
	check_timer.wait_time = 0.5
	check_timer.timeout.connect(_check_bounds)
	check_timer.autostart = true
	add_child(check_timer)

func _check_bounds():
	if global_position.y > viewport_size.y + 50:
		weight_fell_off_screen.emit(self)
		queue_free()
