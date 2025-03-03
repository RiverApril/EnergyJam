extends Node

class_name Glow

@export var base_mesh_instance: MeshInstance3D
@export var glow_mesh_instance: MeshInstance3D
@export var objective_mesh_instance: MeshInstance3D

var colored_glow_material: ShaderMaterial
var current_RGB: int = 0
var objective_RGB: int = 0
var has_objective: bool = false

const TURN_OFF_TIME = 0.01
var timer = 0.0

@export var charge_time = 1.0
var charged_progress = 0.0

var emitter_child: Emitter = null
var cuttable: Cuttable = null

func _ready():
	EventBus.something_moved_signal.connect(on_something_moved_signal)
	# print(get_parent().name)
	# print(glow_mesh_instance)
	colored_glow_material = glow_mesh_instance.get_active_material(0).duplicate()
	glow_mesh_instance.material_override = colored_glow_material
	glow_mesh_instance.visible = false
	base_mesh_instance.visible = true

	var parent = get_parent()
	objective_RGB = (0b100 if parent.get_meta("objective_red", false) else 0)\
		| (0b010 if parent.get_meta("objective_green", false) else 0)\
		| (0b001 if parent.get_meta("objective_blue", false) else 0)
	
	has_objective = parent.has_meta("objective_red") or parent.has_meta("objective_green") or parent.has_meta("objective_blue");
	
	if has_objective:
		var colored_objective_material = objective_mesh_instance.get_active_material(0).duplicate()
		objective_mesh_instance.material_override = colored_objective_material
		colored_objective_material.set_shader_parameter("albedo_color", Globals.laser_display_colors[objective_RGB])

	
	if has_node("Emitter"):
		emitter_child = get_node("Emitter")

	if parent.has_node("Cuttable"):
		cuttable = parent.get_node("Cuttable")
		has_objective = false

func _process(delta: float):
	if timer > 0.0:
		timer -= delta
	elif timer < 0.0:
		timer = 0.0
		charged_progress = 0.0
		glow_mesh_instance.visible = false
		base_mesh_instance.visible = true
		update_emitter_child()

	if current_RGB > 0:
		if charged_progress < 1.0:
			charged_progress += delta / charge_time
		elif charged_progress > 1.0:
			charged_progress = 1.0
			EventBus.check_win_signal.emit()
			if cuttable != null and is_objective_met():
				cuttable.do_cut()

		colored_glow_material.set_shader_parameter("on_ness", charged_progress)

		


func on_something_moved_signal():
	if timer == 0.0:
		timer = TURN_OFF_TIME
		current_RGB = 0

func turn_on(rgb: int):
	timer = 0.0
	current_RGB |= rgb
	update_emitter_child()

	colored_glow_material.set_shader_parameter("albedo_color", Globals.laser_display_colors[current_RGB])
	colored_glow_material.set_shader_parameter("on_ness", charged_progress)
	glow_mesh_instance.visible = true
	base_mesh_instance.visible = false
	
	if is_objective_met():
		EventBus.check_win_signal.emit()

func update_emitter_child():
	if emitter_child != null:
		# print(current_RGB)
		emitter_child.beam_rgb = current_RGB
		emitter_child.needs_update = true

func is_objective_met():
	return current_RGB == objective_RGB and charged_progress == 1.0
