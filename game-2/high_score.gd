extends Node

const SAVE_FILE = "user://highscore.save"
var high_score = 0

func _ready():
	load_high_score()

func load_high_score():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var save_data = json.data
				if save_data.has("high_score"):
					high_score = save_data["high_score"]
	
func save_high_score():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var save_data = {
			"high_score": high_score
		}
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()

func check_and_update_high_score(new_score: int) -> bool:
	if new_score > high_score:
		high_score = new_score
		save_high_score()
		return true
	return false

func get_high_score() -> int:
	return high_score
