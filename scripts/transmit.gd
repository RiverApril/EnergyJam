extends Node

class_name Transmit

@export var mesh_to_color: MeshInstance3D
var allow_RGB: int = 0

func _ready():
	var parent = get_parent()
	allow_RGB = (0b100 if parent.get_meta("transmit_red", true) else 0)\
		| (0b010 if parent.get_meta("transmit_green", true) else 0)\
		| (0b001 if parent.get_meta("transmit_blue", true) else 0)

	if mesh_to_color != null:
		var material = mesh_to_color.get_active_material(0)
		var colored_material: StandardMaterial3D = material.duplicate()
		colored_material.albedo_color = Globals.laser_display_colors[allow_RGB]
		mesh_to_color.material_override = colored_material
