extends Camera2D

var SCREEN_SIZE: Vector2 = Vector2i(1920,1080)
var camera_xy: Vector2 = Vector2(1920,1080)/2
var busy: bool = false

func _ready() -> void:
	global_position = camera_xy
	pass

func _process(delta: float) -> void:
	pass

# gradually move camera by offset
func slide_by_offset(_offset: Vector2) -> void:
	if busy: return
	busy = true
	camera_xy += _offset
	var tw := create_tween()
	tw.tween_property(self, "global_position", camera_xy, .32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(func(): busy = false)

# move directly to location by offset
func move_by_offset(_offset: Vector2) -> void:
	camera_xy += _offset
	global_position = camera_xy

# gradually move camera to new location
func slide_to(location: Vector2) -> void:
	var target = camera_xy - location
	slide_by_offset(target)
	
# move directly to location
func move_to(location: Vector2) -> void:
	var target = camera_xy - location
	move_by_offset(target)

func move_camera_right() -> void:
	move_by_offset(Vector2(1920,0))
func move_camera_left() -> void:
	move_by_offset(Vector2(-1920,0))
	
func slide_camera_right() -> void:
	slide_by_offset(Vector2(1920,0))
func slide_camera_left() -> void:
	slide_by_offset(Vector2(-1920,0))
