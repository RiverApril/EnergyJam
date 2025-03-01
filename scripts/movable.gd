extends StaticBody3D

class_name Movable

signal ran_into_something_signal(collision, direction);

var move_speed: float = Globals.default_block_move_speed

var is_moving: bool = false
var target_position: Vector3
var previous_position: Vector3

func _ready() -> void:
	previous_position = position
	target_position = position

func push(direction: Vector3) -> bool:
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
