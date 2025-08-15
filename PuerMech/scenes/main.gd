extends Node2D

const BASE_RESOLUTION: Vector2 = Vector2(1920, 1080)

# We're going to assume this is desktop (mostly for development)
# if false it's web target
var is_desktop: bool = true
var is_fullscreen: bool = false
@onready var ui_root: Control = $UIRoot

# if false, use room scripts
var camera_follow = true

func _ready():
	#var is_desktop = (OS.has_feature("pc") or 
	#				 OS.has_feature("macos") or  
	#				 OS.has_feature("linux"))
	if OS.has_feature("web"):
		is_desktop = false
		
	if is_desktop:
		print("Starting") 
		print("Setting full screen to " + str(is_fullscreen))
		set_borderless_fullscreen(is_fullscreen)
	if not is_desktop:
		print("Starting") 
		print("Web Version Detected")
		# if you want to get where the game is running from (like itch.io)
		# var hostname: String = JavaScriptBridge.eval("window.location.hostname")
		await get_tree().process_frame
		get_viewport().size_changed.connect(_apply_scale)
		_apply_scale()
	$Player/Camera2D.make_current()
	
func _apply_scale():
	var vp := get_viewport().get_visible_rect().size
	var s : float = min(vp.x / BASE_RESOLUTION.x, vp.y / BASE_RESOLUTION.y) 
	# Round to pixel scale
	s = floor(s * 100.0) / 100.0
	ui_root.scale = Vector2(s, s)

	# Scale and center
	var scaled_size: Vector2 = BASE_RESOLUTION * s
	ui_root.position = (vp - scaled_size) * 0.5
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("CloseGame"):
		if is_desktop:
			get_tree().quit(0)
		else:
			get_tree().paused = true
	if Input.is_action_just_pressed("SwitchWindow"):
		is_fullscreen = not is_fullscreen
		set_borderless_fullscreen(is_fullscreen)
		
	$CanvasLayer/UIRoot/YVel.text = "Velocity: " + str(floor(-1*$Player.velocity.y))
	
func set_borderless_fullscreen(enable: bool):
	if enable:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		var screen_size = DisplayServer.screen_get_size()
		DisplayServer.window_set_size(screen_size)
		DisplayServer.window_set_position(Vector2i(0, 0))
	else:
		var screen_size = DisplayServer.screen_get_size()
		#Make the window half the size
		var window_size = screen_size / 2
		#Position the screen to be center screen
		var screen_pos = window_size / 2
		
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(window_size)
		DisplayServer.window_set_position(screen_pos)
