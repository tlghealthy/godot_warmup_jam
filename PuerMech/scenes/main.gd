extends Node2D

var is_fullscreen = false

func _ready():
	if OS.has_feature("pc"): 
		print("Setting full screen to ")
		print(is_fullscreen)
		set_borderless_fullscreen(is_fullscreen)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Close_Game"):
		get_tree().quit(0)
	if Input.is_action_just_pressed("SwitchWindow"):
		is_fullscreen = not is_fullscreen
		set_borderless_fullscreen(is_fullscreen)

func set_borderless_fullscreen(enable: bool):
	if enable:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		var screen_size = DisplayServer.screen_get_size()
		DisplayServer.window_set_size(screen_size)
		DisplayServer.window_set_position(Vector2i(0, 0))
	else:
		
		var screen_size = DisplayServer.screen_get_size()
		var window_size = screen_size/ 2
		var screen_pos = screen_size/ 2
		screen_pos.x = screen_pos.x / 2
		screen_pos.y = screen_pos.y / 2
		
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(window_size)
		DisplayServer.window_set_position(screen_pos)
