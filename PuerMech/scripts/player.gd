extends CharacterBody2D

@export var speed := 1200          # Horizontal movement speed (pixels/second)
@export var jump_speed := -1800    # Upward velocity when jumping (negative because y axis is down)
@export var gravity := 4000        # Gravity force applied each frame

func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta

	# Get horizontal input: returns -1, 0 or 1 based on walk_left/walk_right actions
	velocity.x = Input.get_axis("walk_left", "walk_right") * speed

	# Move and collide using built‑in function
	move_and_slide()

	# Jump only when on the floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
