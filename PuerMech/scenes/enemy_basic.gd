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

@onready var health: Node = $Health
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
	var target_dir: Vector2 = Vector2.RIGHT * patrol_dir
	if face_player:
		var player_node: Node2D = get_tree().get_first_node_in_group("player") as Node2D
		if player_node:
			var to_player: Vector2 = (player_node.global_position - global_position).normalized()
			if to_player != Vector2.ZERO:
				target_dir = to_player
	var spawn_pos: Vector2 = global_position
	if target_dir.x >= 0.0 and is_instance_valid(muzzle_right):
		spawn_pos = muzzle_right.global_position
	elif is_instance_valid(muzzle_left):
		spawn_pos = muzzle_left.global_position
	var p = projectile_scene.instantiate()
	if p is Node2D:
		p.global_position = spawn_pos
	# Set projectile direction dynamically (scripted property on the projectile)
	p.set("direction", target_dir)
	get_tree().current_scene.add_child(p)

func _on_died() -> void:
	queue_free()
