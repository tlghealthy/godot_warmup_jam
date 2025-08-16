extends CanvasLayer

signal restart_game
signal quit_game

func _ready():
	$Control/VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$Control/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func show_game_over(final_score: int):
	$Control/VBoxContainer/ScoreDisplay.text = "Final Score: " + str(final_score)
	$Control/VBoxContainer/HighScoreDisplay.text = "High Score: " + str(HighScore.get_high_score())
	
	var is_new_high_score = HighScore.check_and_update_high_score(final_score)
	if is_new_high_score:
		$Control/VBoxContainer/NewHighScoreLabel.visible = true
		$Control/VBoxContainer/HighScoreDisplay.text = "High Score: " + str(HighScore.get_high_score())
	
	visible = true

func _on_restart_pressed():
	restart_game.emit()

func _on_quit_pressed():
	quit_game.emit()
