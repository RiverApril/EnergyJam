extends Node

class_name Glow

@export var mesh_instance: MeshInstance3D
@export var off_material: Material
@export var on_material: StandardMaterial3D

var current_colors: Array = Array()
var colored_on_material: StandardMaterial3D = null

const TURN_OFF_TIME = 0.01
var timer = 0.0


func _ready():
	EventBus.something_moved_signal.connect(on_something_moved_signal)
	mesh_instance.material_override = off_material

	if colored_on_material == null:
		colored_on_material = on_material.duplicate()
	mesh_instance.material_override = colored_on_material

func _process(delta: float):
	if timer > 0.0:
		timer -= delta
	elif timer < 0.0:
		timer = 0.0
		mesh_instance.material_override = off_material


func on_something_moved_signal():
	timer = TURN_OFF_TIME
	current_colors.clear()

func turn_on(color: Color):
	timer = 0.0
	current_colors.append(color)

	var combined_color = Color.BLACK
	for a_color in current_colors:
		combined_color += a_color
	combined_color /= current_colors.size()

	colored_on_material.albedo_color = combined_color
	mesh_instance.material_override = colored_on_material
