extends Node2D

signal warning_expired(position: Vector2, weight_type: String)

func _ready():
	$AnimatedSprite2D.play("blue_animation")
	
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	warning_expired.emit(position, "blue")
	queue_free()