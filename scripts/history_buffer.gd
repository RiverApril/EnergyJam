extends Node

signal update_state_signal();
signal new_state_signal();

var current_state_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("Undo"):
		undo()

	if Input.is_action_just_pressed("Reset"):
		reset()

	

func start_new_state():
	current_state_index += 1
	# print("start new state ", current_state_index)
	new_state_signal.emit()

func get_current_state_index() -> int:
	return current_state_index

func undo():
	if current_state_index > 0:
		current_state_index -= 1
		update_state_signal.emit()
	# print("undo ", current_state_index)

func reset():
	current_state_index = 0
	update_state_signal.emit()
	current_state_index = -1
	start_new_state()
	# print("reset ", current_state_index)