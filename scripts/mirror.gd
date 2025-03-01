extends Node

class_name Mirror

@export var mesh_to_color: MeshInstance3D
var reflect_RGB: int = 0

func _ready():
	var parent = get_parent()
	reflect_RGB = (0b100 if parent.get_meta("reflect_red", true) else 0)\
		| (0b010 if parent.get_meta("reflect_green", true) else 0)\
		| (0b001 if parent.get_meta("reflect_blue", true) else 0)

	if mesh_to_color != null:
		var material = mesh_to_color.get_active_material(0)
		var colored_material: StandardMaterial3D = material.duplicate()
		colored_material.albedo_color = Globals.laser_display_colors[reflect_RGB]
		mesh_to_color.material_override = colored_material
