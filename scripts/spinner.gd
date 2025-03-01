extends Node

@export var target: Node3D
@export var angular_velocity: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var angle = angular_velocity.length()
	var axis = angular_velocity / angle
	target.rotate(axis, angle * delta)
	EventBus.something_moved_signal.emit()
