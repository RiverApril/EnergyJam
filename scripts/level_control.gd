extends Node

@export var all_levels: AllLevels

func _input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			go_to_next_level()

func go_to_next_level():
	Globals.current_level_index += 1
	if Globals.current_level_index >= all_levels.levels.size():
		Globals.current_level_index = 0
	
	var level_path = all_levels.levels_folder + all_levels.levels[Globals.current_level_index] + ".tscn"
	HistoryBuffer.reset()
	get_tree().change_scene_to_file(level_path)
