extends Node2D

var weight_scene = preload("res://1kg.tscn")
var heavy_weight_scene = preload("res://2kg.tscn")
var light_weight_scene = preload("res://3kg.tscn")
var pause_menu_scene = preload("res://pause_menu.tscn")
var red_warning_scene = preload("res://red_exclamation.tscn")
var blue_warning_scene = preload("res://blue_exclamation.tscn")
var green_warning_scene = preload("res://green_exclamation.tscn")
var game_over_scene = preload("res://game_over.tscn")
var is_paused = false
var is_game_over = false
var pause_menu
var game_over_menu
var cycle_timer
var score_timer
var warning_positions = []
var score = 0
var score_label
var high_score_label
var score_mult = 1
var current_level = 1
var level_timer
var countdown_label
var level_time_label
var level_time_remaining = 10.0
var level_countdown_timer
var is_level_transitioning = false
var is_in_countdown = false

func _ready():
	setup_pause_menu()
	setup_game_over_menu()
	setup_cycle_timer()
	setup_score_system()
	setup_level_system()

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_I and event.pressed and not is_paused and not is_game_over and not is_in_countdown:
			spawn_weight(get_global_mouse_position())
		elif event.keycode == KEY_K and event.pressed and not is_paused and not is_game_over and not is_in_countdown and current_level >= 2:
			spawn_weight(get_global_mouse_position(), "blue")
		elif event.keycode == KEY_L and event.pressed and not is_paused and not is_game_over and not is_in_countdown and current_level >= 4:
			spawn_weight(get_global_mouse_position(), "green")
		elif event.keycode == KEY_ESCAPE and event.pressed and not is_game_over:
			toggle_pause()

func spawn_weight(position: Vector2, weight_type: String = "red"):
	if is_game_over:
		return
		
	var weight_instance
	if weight_type == "blue":
		weight_instance = heavy_weight_scene.instantiate()
	elif weight_type == "green":
		weight_instance = light_weight_scene.instantiate()
	else:
		weight_instance = weight_scene.instantiate()
	
	weight_instance.position = position
	
	# Connect to the RigidBody2D child which has the script
	var rigid_body = weight_instance.get_node("RigidBody2D")
	rigid_body.weight_fell_off_screen.connect(_on_weight_fell_off_screen)
	
	add_child(weight_instance)

func setup_pause_menu():
	pause_menu = pause_menu_scene.instantiate()
	pause_menu.visible = false
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.quit_game.connect(_on_quit_game)
	add_child(pause_menu)

func toggle_pause():
	is_paused = !is_paused
	pause_menu.visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		cycle_timer.paused = true
		score_timer.paused = true
		if level_timer:
			level_timer.paused = true
		if level_countdown_timer:
			level_countdown_timer.paused = true
	else:
		cycle_timer.paused = false
		score_timer.paused = false
		if level_timer:
			level_timer.paused = false
		if level_countdown_timer:
			level_countdown_timer.paused = false

func _on_resume_game():
	toggle_pause()

func _on_quit_game():
	get_tree().quit()

func setup_cycle_timer():
	cycle_timer = Timer.new()
	cycle_timer.wait_time = 5.0
	cycle_timer.timeout.connect(_on_cycle_timer_timeout)
	cycle_timer.autostart = true
	add_child(cycle_timer)
	spawn_warnings()

func _on_cycle_timer_timeout():
	spawn_warnings()

func spawn_warnings():
	warning_positions.clear()
	var viewport_size = get_viewport().get_visible_rect().size
	
	for i in range(2):
		var random_pos = Vector2(
			randf_range(0.25, 0.75) * viewport_size.x,
			randf_range(0.25, 0.5) * viewport_size.y
		)
		warning_positions.append(random_pos)
		
		var delay = randf() * 5
		get_tree().create_timer(delay).timeout.connect(func(): create_warning_at(random_pos))

func create_warning_at(pos: Vector2):
	if is_level_transitioning or is_in_countdown:
		return
		
	var warning
	var green_chance = get_green_spawn_chance()
	var blue_chance = get_blue_spawn_chance()
	var rand_val = randf()
	
	if rand_val < green_chance:
		warning = green_warning_scene.instantiate()
	elif rand_val < green_chance + blue_chance:
		warning = blue_warning_scene.instantiate()
	else:
		warning = red_warning_scene.instantiate()
	
	warning.position = pos
	warning.warning_expired.connect(_on_warning_expired)
	add_child(warning)

func _on_warning_expired(pos: Vector2, weight_type: String):
	spawn_weight(pos, weight_type)
	score_mult = score_mult + 1


func setup_score_system():
	score_label = $ScoreLabel
	high_score_label = $HighScoreLabel
	update_high_score_display()
	
	score_timer = Timer.new()
	score_timer.wait_time = 1.0
	score_timer.timeout.connect(_on_score_timer_timeout)
	score_timer.autostart = true
	add_child(score_timer)

func _on_score_timer_timeout():
	if not is_game_over and not is_level_transitioning and not is_in_countdown:
		add_score(10*score_mult)

func add_score(points: int):
	score += points
	score_label.text = "Score: " + str(score)

func update_high_score_display():
	high_score_label.text = "High: " + str(HighScore.get_high_score())

func setup_game_over_menu():
	game_over_menu = game_over_scene.instantiate()
	game_over_menu.visible = false
	game_over_menu.restart_game.connect(_on_restart_game)
	game_over_menu.quit_game.connect(_on_quit_game)
	add_child(game_over_menu)

func _on_weight_fell_off_screen(weight_node):
	trigger_game_over()

func trigger_game_over():
	is_game_over = true
	cycle_timer.paused = true
	score_timer.paused = true
	if level_timer:
		level_timer.paused = true
	if level_countdown_timer:
		level_countdown_timer.paused = true
	game_over_menu.show_game_over(score)

func _on_restart_game():
	# Update high score display in case it changed
	update_high_score_display()
	get_tree().reload_current_scene()

func setup_level_system():
	countdown_label = $CountdownLabel
	level_time_label = $LevelTimeLabel
	level_time_remaining = get_level_duration(current_level)
	
	level_timer = Timer.new()
	level_timer.wait_time = get_level_duration(current_level)
	level_timer.timeout.connect(_on_level_complete)
	level_timer.one_shot = true
	add_child(level_timer)
	level_timer.start()
	
	# Timer to update countdown display every second
	level_countdown_timer = Timer.new()
	level_countdown_timer.wait_time = 1.0
	level_countdown_timer.timeout.connect(_on_level_countdown_update)
	level_countdown_timer.autostart = true
	add_child(level_countdown_timer)
	
	update_level_display()
	update_level_time_display()

func update_level_display():
	$LevelLabel.text = "Level: " + str(current_level)

func update_level_time_display():
	if is_in_countdown:
		level_time_label.text = "Time: -"
	else:
		var time_left = int(level_time_remaining)
		level_time_label.text = "Time: " + str(time_left)

func _on_level_countdown_update():
	if not is_level_transitioning and not is_in_countdown and not is_paused:
		level_time_remaining -= 1.0
		update_level_time_display()

func _on_level_complete():
	# Award level completion bonus (level duration * 10)
	var level_duration = get_level_duration(current_level)
	var bonus_points = int(level_duration * 10)
	add_score(bonus_points)
	
	is_level_transitioning = true
	cycle_timer.paused = true
	score_timer.paused = true
	score_mult = 1
	clear_all_blocks()
	start_level_countdown()

func clear_all_blocks():
	# Remove all weights and warnings, but keep scene-defined nodes
	var children = get_children()
	for child in children:
		# Check if it's a spawned weight (has RigidBody2D with weight_checker script)
		if child.has_node("RigidBody2D"):
			var rigid_body = child.get_node("RigidBody2D")
			if rigid_body.get_script() != null:
				child.queue_free()
		# Check if it's a spawned warning (has AnimatedSprite2D and warning script)
		elif child.has_node("AnimatedSprite2D") and child.get_script() != null:
			child.queue_free()
	
	# Reset beam orientation
	reset_beam_orientation()

func reset_beam_orientation():
	var beam_system = $"Node2D"
	if beam_system:
		# Store the beam's position
		var beam_position = beam_system.position
		
		# Remove the old beam
		beam_system.queue_free()
		
		# Wait a frame for cleanup
		await get_tree().process_frame
		
		# Create a new beam instance
		var beam_scene = preload("res://beam.tscn")
		var new_beam = beam_scene.instantiate()
		new_beam.position = beam_position
		new_beam.name = "Node2D"
		add_child(new_beam)

func start_level_countdown():
	is_in_countdown = true
	countdown_label.visible = true
	current_level += 1
	update_level_display()
	update_level_time_display()
	
	countdown_from_3()

func countdown_from_3():
	countdown_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "GO!"
	await get_tree().create_timer(1.0).timeout
	
	end_countdown()

func end_countdown():
	countdown_label.visible = false
	is_in_countdown = false
	is_level_transitioning = false
		
	# Reset level time for new level
	var new_duration = get_level_duration(current_level)
	level_time_remaining = new_duration
	update_level_time_display()
	
	# Resume timers
	score_timer.paused = false
	setup_cycle_timer()
	
	# Start new level timer with correct duration
	level_timer.wait_time = new_duration
	level_timer.start()

func get_level_duration(level: int) -> float:
	match level:
		1:
			return 10.0  # Level 1: 10 seconds
		2:
			return 15.0  # Level 2: 15 seconds
		_:
			return 20.0 + (2.0 * (level-3))  # Level 3+: 20 + (2 × level)

func get_blue_spawn_chance() -> float:
	match current_level:
		1:
			return 0.0  # No blue in level 1
		2:
			return 0.1  # 10% in level 2
		3:
			return 0.15  # 15% in level 3
		_:
			return 0.2 + (0.02 * (current_level - 4))  # 20% in level 4+

func get_green_spawn_chance() -> float:
	match current_level:
		1, 2, 3:
			return 0.0  # No green until level 4
		4:
			return 0.05  # 5% in level 4
		_:
			return 0.1 + (0.02 * (current_level - 4))  # 5% + 10% per level after 4
