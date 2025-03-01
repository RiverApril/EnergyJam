extends Node3D

class_name Prism

@export var mesh_insatance: MeshInstance3D
@export var refraction_index: float = 1.5

var normals: Array = Array()

func _ready():
	var surface_tool := SurfaceTool.new()
	surface_tool.create_from(mesh_insatance.mesh,0)
	var array_mesh := surface_tool.commit()
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(array_mesh, 0)
	for i in range(mdt.get_face_count()):
		var face_normal = mdt.get_face_normal(i)
		var oriented_normal = mesh_insatance.transform.basis * face_normal
		normals.append(oriented_normal)

func get_normals() -> Array:
	return normals
