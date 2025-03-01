extends Node

@export var levels: Array # PackedScene Array

func _input(event):
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			go_to_next_level()

func go_to_next_level():
	pass #todo
