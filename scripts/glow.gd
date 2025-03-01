extends Node

class_name Glow

@export var base_mesh_instance: MeshInstance3D
@export var glow_mesh_instance: MeshInstance3D

var colored_glow_material: ShaderMaterial
var current_RGB: int = 0

const TURN_OFF_TIME = 0.01
var timer = 0.0

var emitter_child: Emitter = null

func _ready():
	EventBus.something_moved_signal.connect(on_something_moved_signal)
	print(get_parent().name)
	print(glow_mesh_instance)
	colored_glow_material = glow_mesh_instance.get_active_material(0).duplicate()
	glow_mesh_instance.material_override = colored_glow_material
	glow_mesh_instance.visible = false
	base_mesh_instance.visible = true
	
	if has_node("Emitter"):
		emitter_child = get_node("Emitter")

func _process(delta: float):
	if timer > 0.0:
		timer -= delta
	elif timer < 0.0:
		timer = 0.0
		glow_mesh_instance.visible = false
		base_mesh_instance.visible = true
		update_emitter_child()


func on_something_moved_signal():
	timer = TURN_OFF_TIME
	current_RGB = 0

func turn_on(rgb: int):
	timer = 0.0
	current_RGB |= rgb
	update_emitter_child()

	colored_glow_material.set_shader_parameter("albedo_color", Globals.laser_display_colors[current_RGB])
	glow_mesh_instance.visible = true
	base_mesh_instance.visible = false

func update_emitter_child():
	if emitter_child != null:
		# print(current_RGB)
		emitter_child.beam_rgb = current_RGB
		emitter_child.needs_update = true
