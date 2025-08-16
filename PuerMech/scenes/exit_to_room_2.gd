extends Area2D


func _on_body_entered(body: Node) -> void:
	if body.name != "Player": return
	$CollisionShape2D.set_deferred("disabled", true)
