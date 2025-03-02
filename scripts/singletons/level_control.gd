extends Node

var all_levels: AllLevels

func _ready():
	all_levels = load("res://datas/all_levels.tres")

func _input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			go_to_next_level()

func reload_curret_level():
	load_level(Globals.current_level_index)

func go_to_next_level():
	Globals.current_level_index += 1
	if Globals.current_level_index >= all_levels.levels.size():
		Globals.current_level_index = 0

	load_level(Globals.current_level_index)

func load_level(index: int):
	var level_path = all_levels.levels_folder + all_levels.levels[index] + ".tscn"
	HistoryBuffer.reset()
	get_tree().change_scene_to_file(level_path)
