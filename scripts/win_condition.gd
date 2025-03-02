extends Node

var all_glows: Array

var win_check_timer: float = 0.0
const WIN_CHECK_DELAY: float = 0.1

func _ready() -> void:
	EventBus.something_moved_signal.connect(on_something_moved_signal)

	all_glows = Array()
	var root = find_root(self)
	find_all_glows(root, all_glows)

func _process(delta: float):
	if win_check_timer > 0.0:
		win_check_timer -= delta
	elif win_check_timer < 0.0:
		win_check_timer = 0.0
		check_win()

func find_all_glows(node: Node, nodes: Array):
	# print(node.name)
	if node is Glow:
		nodes.push_back(node)
	for child in node.get_children():
		find_all_glows(child, nodes)

func find_root(node: Node) -> Node:
	var parent = node.get_parent()
	if parent == null:
		return node
	return find_root(parent)

func on_something_moved_signal():
	win_check_timer = WIN_CHECK_DELAY

func check_win():
	if are_all_objectives_met():
		win()

func win():
	# todo, make a transition or something
	LevelControl.go_to_next_level()


func are_all_objectives_met() -> bool:
	if all_glows.size() == 0:
		return false
	
	for glow: Glow in all_glows:
		if glow.has_objective:
			# print(glow.objective_RGB, " == ", glow.current_RGB, " ?")
			if !glow.is_objective_met():
				return false
	return true
