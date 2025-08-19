extends CharacterBody2D

@export var move_speed: float = 120.0
@export var patrol_distance: float = 200.0
@export var shoot_cooldown: float = 1.2
@export var projectile_scene: PackedScene
@export var gravity: float = 2000.0
@export var face_player: bool = true

var start_position: Vector2
var patrol_dir: int = 1
var shoot_timer: float = 0.0

@onready var health = $Health
@onready var muzzle_left: Node2D = $MuzzleLeft
@onready var muzzle_right: Node2D = $MuzzleRight

func _ready() -> void:
	start_position = global_position
	if health:
		health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	var offset := global_position.x - start_position.x
	if abs(offset) > patrol_distance:
		patrol_dir *= -1
	velocity.x = patrol_dir * move_speed
	move_and_slide()

	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = shoot_cooldown
		_shoot()

func _shoot() -> void:
	if projectile_scene == null:
		return
	var target_dir := Vector2.RIGHT * patrol_dir
	if face_player:
		var player := get_tree().get_first_node_in_group("player")
		if player and player is Node2D:
			var to_player := (player.global_position - global_position).normalized()
			if to_player.length() > 0:
				target_dir = to_player
	var spawn := muzzle_right if target_dir.x >= 0 else muzzle_left
	var p: Area2D = projectile_scene.instantiate()
	p.global_position = spawn.global_position if spawn else global_position
	if p.has_method("set"):
		pass
	if p.has_variable("direction"):
		p.direction = target_dir
	elif p.has_method("set_direction"):
		p.set_direction(target_dir)
	get_tree().current_scene.add_child(p)

func _on_died() -> void:
	queue_free()
