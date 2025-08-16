extends Node2D

signal warning_expired(position: Vector2)

func _ready():
	$AnimationPlayer.play("flash")
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start()

func _on_timer_timeout():
	warning_expired.emit(position)
	queue_free()
