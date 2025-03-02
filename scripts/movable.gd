extends StaticBody3D

class_name Movable

signal ran_into_something_signal(collision, direction);

@export var can_move_h: bool = true
@export var can_move_v: bool = true

var move_speed: float = Globals.default_block_move_speed

var is_moving: bool = false
var target_position: Vector3
var previous_position: Vector3

var state_history: Dictionary

func _ready() -> void:
	previous_position = position
	target_position = position
	HistoryBuffer.update_state_signal.connect(on_update_state_signal)
	HistoryBuffer.new_state_signal.connect(on_new_state_signal)

	save_state(HistoryBuffer.get_current_state_index())

func on_update_state_signal() -> void:
	var new_state_index = HistoryBuffer.get_current_state_index()
	load_state(new_state_index)

func on_new_state_signal() -> void:
	if !state_history.has(0):
		save_state(0)
	save_state(HistoryBuffer.get_current_state_index())

func load_state(index: int):
	if !state_history.has(index):
		return
	var new_state = state_history[index];
	position = new_state["position"]
	target_position = position
	previous_position = position

	EventBus.something_moved_signal.emit()

func save_state(index: int):
	state_history[index] = {
		"position": position
	}
	# print("saved: ", index)


func push(direction: Vector3) -> bool:
	var parent = get_parent()
	if parent and parent.has_method("stop_anim"):
		parent.stop_anim()

	if !can_move_h:
		direction.x = 0
	if !can_move_v:
		direction.z = 0

	if !is_moving and !direction.is_zero_approx():
		is_moving = true
		previous_position = position
		target_position = position + Vector3(sign(direction.x), sign(direction.y), sign(direction.z))
		return true
	return false

func _physics_process(delta: float) -> void:

	if is_moving:
		var collision := move_and_collide((target_position - position).normalized() * move_speed * delta)

		if collision:
			ran_into_something_signal.emit(collision, target_position-previous_position)
			target_position = previous_position

		EventBus.something_moved_signal.emit()

	var snap_epsilon = move_speed * delta

	if is_moving and (position - target_position).length_squared() < snap_epsilon * snap_epsilon:
		position = target_position
		is_moving = false
		EventBus.something_moved_signal.emit()
		save_state(HistoryBuffer.get_current_state_index())
