extends CharacterBody2D


const SPEED = 500.0
const ACCELERATION = 1500.0
const FRICTION = 1700.0
const JUMP_FORCE = 500.0
var max_jumps = 2
var max_jump_time = .3
var cur_jumps = max_jumps
var jump_charge_time = max_jump_time
var is_jumping = false
var was_on_floor = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
	var direction = Input.get_axis("PlayerWalkLeft", "PlayerWalkRight")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0 , FRICTION * delta)
	var on_floor = is_on_floor()
	if not on_floor:
		if is_on_ceiling():
			velocity.y = 200
			jump_charge_time = 0
			cur_jumps = max_jumps
			
		else:
			if Input.is_action_just_released("PlayerJump") and cur_jumps > 0:
				cur_jumps -= 1
				if cur_jumps:
					jump_charge_time = max_jump_time
			
			if Input.is_action_pressed("PlayerJump") and jump_charge_time > 0 and cur_jumps > 0:
				velocity.y = -JUMP_FORCE
				jump_charge_time -= delta
			else:
				velocity.y += gravity * delta
	else:
		if was_on_floor:
			is_jumping = false
			jump_charge_time = max_jump_time
			cur_jumps = max_jumps
		if Input.is_action_just_pressed("PlayerJump"):
			is_jumping = true
			velocity.y = -JUMP_FORCE
	was_on_floor = on_floor
			
	if velocity.x == 0:
		$AnimationPlayer.play("RESET")
	elif velocity.x > 0:
		$AnimationPlayer.play("AnmMechWalkRight")
	elif velocity.x < 0:
		$AnimationPlayer.play("AnmMechWalkLeft")
	move_and_slide()
