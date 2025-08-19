extends CharacterBody2D

@export var move_speed: float = 120.0
@export var patrol_distance: float = 200.0
@export var shoot_cooldown: float = 1.2
@export var projectile_scene: PackedScene
@export var gravity: float = 2000.0
@export var face_player: bool = true
@export var aggro_range: float = 420.0
@export var drop_scene: PackedScene

var start_position: Vector2
var patrol_dir: int = 1
var shoot_timer: float = 0.0

enum State { PATROL, CHASE }
var state: State = State.PATROL

@onready var health: Node = $Health
@onready var muzzle_left: Node2D = $MuzzleLeft
@onready var muzzle_right: Node2D = $MuzzleRight

func _ready() -> void:
	start_position = global_position
	if health:
		health.died.connect(_on_died)
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	_update_state()
	if state == State.PATROL:
		var offset: float = global_position.x - start_position.x
		if abs(offset) > patrol_distance:
			patrol_dir *= -1
		velocity.x = patrol_dir * move_speed
	else:
		var player_node: Node2D = get_tree().get_first_node_in_group("player") as Node2D
		if player_node:
			var dir: float = sign((player_node.global_position.x - global_position.x))
			velocity.x = dir * move_speed
	move_and_slide()

	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = shoot_cooldown
		_shoot()

func _update_state() -> void:
	var player_node: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if not player_node:
		state = State.PATROL
		return
	var dist: float = global_position.distance_to(player_node.global_position)
	state = State.CHASE if dist <= aggro_range else State.PATROL

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
	# Ensure friendly-fire rules: enemies target the player group by default
	if p.has_method("set"):
		pass
	p.set("target_groups", [StringName("player")])
	p.set("ignore_groups", [StringName("enemy")])
	get_tree().current_scene.add_child(p)

func _on_died() -> void:
	_spawn_death_effect()
	if drop_scene:
		var drop = drop_scene.instantiate()
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
	queue_free()

func _spawn_death_effect() -> void:
	var pop := Node2D.new()
	pop.global_position = global_position
	var s := ColorRect.new()
	s.color = Color(1, 0.5, 0.2, 0.9)
	s.size = Vector2(8, 8)
	s.position = Vector2(-4, -4)
	pop.add_child(s)
	get_tree().current_scene.add_child(pop)
	var tw := pop.create_tween()
	tw.tween_property(s, "scale", Vector2(4, 4), 0.35)
	tw.tween_property(s, "modulate:a", 0.0, 0.35)
	tw.finished.connect(func(): pop.queue_free())
