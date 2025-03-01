extends Node

class_name Glow

@export var mesh_instance: MeshInstance3D
@export var off_material: Material
@export var on_material: StandardMaterial3D

var colored_on_material: StandardMaterial3D = null
var current_RGB: int = 0

const TURN_OFF_TIME = 0.01
var timer = 0.0

var emitter_child: Emitter = null

func _ready():
	EventBus.something_moved_signal.connect(on_something_moved_signal)
	mesh_instance.material_override = off_material

	if colored_on_material == null:
		colored_on_material = on_material.duplicate()
	
	if has_node("Emitter"):
		emitter_child = get_node("Emitter")

func _process(delta: float):
	if timer > 0.0:
		timer -= delta
	elif timer < 0.0:
		timer = 0.0
		mesh_instance.material_override = off_material
		update_emitter_child()


func on_something_moved_signal():
	timer = TURN_OFF_TIME
	current_RGB = 0

func turn_on(rgb: int):
	timer = 0.0
	current_RGB |= rgb
	update_emitter_child()

	colored_on_material.albedo_color = Globals.laser_display_colors[current_RGB]
	mesh_instance.material_override = colored_on_material

func update_emitter_child():
	if emitter_child != null:
		print(current_RGB)
		emitter_child.beam_rgb = current_RGB
		emitter_child.needs_update = true