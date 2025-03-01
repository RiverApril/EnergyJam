extends Node

@export var movable: Movable

func _ready() -> void:
	movable.ran_into_something_signal.connect(on_ran_into_something_signal)

func on_ran_into_something_signal(collision: KinematicCollision3D, direction: Vector3) -> void:
	var other = collision.get_collider()
	for child in other.get_children():
		if child is Movable:
			var other_movable: Movable = child
			other_movable.push(direction)


func _physics_process(_delta: float) -> void:
	var input_direction = Input.get_vector("Left", "Right", "Up", "Down")
	movable.push(Vector3(input_direction.x, 0, input_direction.y))
