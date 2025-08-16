extends CanvasLayer

signal resume_game
signal quit_game

func _ready():
	$Control/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			_on_resume_pressed()

func _on_resume_pressed():
	resume_game.emit()

func _on_quit_pressed():
	quit_game.emit()
