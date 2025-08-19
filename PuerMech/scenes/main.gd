extends Node2D

const BASE_RESOLUTION: Vector2 = Vector2(1920, 1080)

# We're going to assume this is desktop (mostly for development)
# if false it's web target
var is_desktop: bool = true
var is_fullscreen: bool = false
@export  var current_camera: Camera2D 
@onready var ui_root: Control = $CanvasLayer/UIRoot

enum CameraType {FOLLOW, TRANSITION, TRANSITION_SMOOTH}
var CameraSet = {
					CameraType.FOLLOW : _camera_follow, 
					CameraType.TRANSITION : _camera_transition,
					CameraType.TRANSITION_SMOOTH : _camera_transition_smooth,
				}
var CurrentCameraType = CameraType.FOLLOW

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
	_camera_set(CameraType.FOLLOW)


func _apply_scale():
	var vp := get_viewport().get_visible_rect().size
	var s : float = min(vp.x / BASE_RESOLUTION.x, vp.y / BASE_RESOLUTION.y) 
	# Round to pixel scale
	s = floor(s * 100.0) / 100.0
	ui_root.scale = Vector2(s, s)

	# Scale and center
	var scaled_size: Vector2 = BASE_RESOLUTION * s
	ui_root.position = (vp - scaled_size) * 0.5

func _camera_set(type:CameraType):
	var NewCameraType = CameraType.keys()[type]
	print("Setting camera to: " + NewCameraType)
	CameraSet[type].call()
	$CanvasLayer/UIRoot/LabCameraType.text = NewCameraType

func _camera_cycle():
	CurrentCameraType = (CurrentCameraType + 1) % CameraType.size() as CameraType
	var NewCameraType = CameraType.keys()[CurrentCameraType]
	print("Cycling camera to: " + NewCameraType)
	CameraSet[CurrentCameraType].call()
	$CanvasLayer/UIRoot/LabCameraType.text = NewCameraType

func is_cameratype_transition() -> bool:
	if CurrentCameraType == CameraType.TRANSITION or CurrentCameraType == CameraType.TRANSITION_SMOOTH:
		return true
	else:
		return false

func _camera_follow():
	current_camera = $Player/Camera2D
	current_camera.make_current()

func _camera_transition():
	current_camera = $ScreenCamera
	current_camera.make_current()
	
func _camera_transition_smooth():
	current_camera = $ScreenCamera
	current_camera.make_current()

func _move_camera_right():
	if CurrentCameraType == CameraType.TRANSITION_SMOOTH:
		current_camera.slide_camera_right()
	elif CurrentCameraType == CameraType.TRANSITION:
		current_camera.move_camera_right()

func _move_camera_left():
	if CurrentCameraType == CameraType.TRANSITION_SMOOTH:
		current_camera.slide_camera_left()
	elif CurrentCameraType == CameraType.TRANSITION:
		current_camera.move_camera_left()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("CloseGame"):
		if is_desktop:
			get_tree().quit(0)
		else:
			get_tree().paused = true
			
	if Input.is_action_just_pressed("SwitchWindow"):
		is_fullscreen = not is_fullscreen
		set_borderless_fullscreen(is_fullscreen)
		
	if Input.is_action_just_pressed("CameraCycle"):
		_camera_cycle()
	
	if Input.is_action_just_pressed("DebugActionRight"):
		_move_camera_right()
	if Input.is_action_just_pressed("DebugActionLeft"):
		_move_camera_left()
	$CanvasLayer/UIRoot/LabYVel.text = "Velocity: " + str(floor(-1*$Player.velocity.y))
	
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



func _on_exit_to_room_2_body_entered(_body: Node2D) -> void:
	_move_camera_right()
