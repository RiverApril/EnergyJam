extends Node

class_name Cuttable

@export var cut_result_top_left_1: Movable
@export var cut_result_top_left_2: Movable
@export var cut_result_top_1: Movable
@export var cut_result_top_2: Movable

var last_direction: Vector3

var movable: Movable

var HIDING_POSITION := Vector3(-1000, -1000, -1000)

var direction_and_splits: Array

func _ready() -> void:
	movable = get_parent()

	cut_result_top_left_1.teleport(HIDING_POSITION)
	cut_result_top_left_2.teleport(HIDING_POSITION)
	cut_result_top_1.teleport(HIDING_POSITION)
	cut_result_top_2.teleport(HIDING_POSITION)

	direction_and_splits = [
		{"direction": Vector3(1, 0, 0),  "scene1": cut_result_top_1,      "scene2": cut_result_top_2,      "angle1": 0.0,  "push1": Vector3(0, 0, -1)},
		{"direction": Vector3(0, 0, 1),  "scene1": cut_result_top_1,      "scene2": cut_result_top_2,      "angle1": 90.0, "push1": Vector3(-1, 0, 0)},
		{"direction": Vector3(1, 0, -1), "scene1": cut_result_top_left_1, "scene2": cut_result_top_left_2, "angle1": 0.0,  "push1": Vector3(-1, 0, -1)},
		{"direction": Vector3(1, 0, 1),  "scene1": cut_result_top_left_1, "scene2": cut_result_top_left_2, "angle1": 90.0, "push1": Vector3(-1, 0, 1)}
	]


func do_cut():

	var best_index: int = -1
	var best_dot: float = 0.0

	for i in range(direction_and_splits.size()):
		var direction_and_split = direction_and_splits[i]
		var direction = direction_and_split["direction"]
		var dot = abs(direction.dot(last_direction))
		if dot > best_dot:
			best_dot = dot
			best_index = i

	if best_index >= 0:
		var direction_and_split = direction_and_splits[best_index]
		var scene1: Movable = direction_and_split["scene1"]
		var scene2: Movable = direction_and_split["scene2"]
		var angle1: float = direction_and_split["angle1"] * PI / 180.0
		var push1: Vector3 = direction_and_split["push1"]

		scene1.teleport(movable.position)
		scene1.push(push1)
		scene1.rotation = Vector3(0.0, angle1, 0.0)

		scene2.teleport(movable.position)
		scene2.push(-push1)
		scene2.rotation = Vector3(0.0, angle1 + PI, 0.0)

		movable.teleport(HIDING_POSITION)








