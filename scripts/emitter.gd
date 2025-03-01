extends Node3D

class_name Emitter

@export var beam_scene: PackedScene

@export var max_beam_depth: int = 10
@export var max_length: float = 100

var beam_holder: Node
var needs_update: bool = true

var beam_rgb: int
# var beam_material: StandardMaterial3D = null
var beam_material: ShaderMaterial = null

var parent: Node3D

const epsilon = 0.01


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	beam_rgb = (0b100 if parent.get_meta("beam_red", false) else 0)\
		| (0b010 if parent.get_meta("beam_green", false) else 0)\
		| (0b001 if parent.get_meta("beam_blue", false) else 0)

	beam_holder = get_node("Beams")
	EventBus.something_moved_signal.connect(on_something_moved_signal)

func on_something_moved_signal() -> void:
	needs_update = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if needs_update:
		needs_update = false
		for child in beam_holder.get_children():
			beam_holder.remove_child(child)
			child.queue_free()

		create_beam(beam_rgb, global_position, (parent.transform.basis * Vector3.FORWARD).normalized(), 0);
	


func create_beam(rgb: int, start_position: Vector3, direction: Vector3, index: int) -> void:
	if index > max_beam_depth:
		return
	
	if rgb == 0:
		return
	
	var end_position = start_position + direction * max_length
	var result := cast_ray(start_position, end_position)

	var hit_position = end_position
	if !result.is_empty():
		hit_position = result["position"]

		var hit_normal: Vector3 = result["normal"]

		var collider = result["collider"]

		# recompute hit point so that it is on the center plane of the mirror so offsets dont propagate
		var plane_position = ray_plane_hit(start_position, direction, hit_normal, -collider.global_position.dot(hit_normal))
		
		if collider.has_node("Mirror"):
			var mirror: Mirror = collider.get_node("Mirror")
			do_reflect(mirror.reflect_RGB & rgb, collider, plane_position, hit_position, direction, hit_normal, index)
		if collider.has_node("Transmit"):
			var transmit: Transmit = collider.get_node("Transmit")
			create_beam(transmit.allow_RGB & rgb, plane_position, direction, index+1)
		if collider.has_node("Prism"):
			do_refract(rgb, collider, hit_position, direction, hit_normal, index)
		if collider.has_node("Glow"):
			if collider.collision_layer & 2:
				var glow: Glow = collider.get_node("Glow")
				glow.turn_on(beam_rgb)
	
	var center_position: Vector3 = (start_position + hit_position) / 2.0
	var length: float = (start_position - hit_position).length()

	if !center_position.is_equal_approx(hit_position):
		var new_beam: Node3D = beam_scene.instantiate()
		new_beam.scale = Vector3(1, 1, length)
		new_beam.look_at_from_position(center_position, hit_position, Vector3.UP)

		var mesh_instance: MeshInstance3D = new_beam.get_node("MeshInstance3D")
		if beam_material == null:
			# var material: StandardMaterial3D = mesh_instance.get_active_material(0)
			var material: ShaderMaterial = mesh_instance.get_active_material(0)
			beam_material = material.duplicate()
		# beam_material.albedo_color = Globals.laser_display_colors[beam_rgb]
		beam_material.set_shader_parameter("albedo_color", Globals.laser_display_colors[beam_rgb])
		mesh_instance.material_override = beam_material

		beam_holder.add_child(new_beam)
		new_beam.owner = beam_holder

func do_reflect(rgb: int, _collider, plane_position: Vector3, _hit_position: Vector3, direction: Vector3, hit_normal: Vector3, index: int) -> void:
	# var mirror: Mirror = collider.get_node("Mirror")
	# print("mirror")
	# var mirror_normal: Vector3 = (collider.transform.basis * mirror.reflection_normal).normalized()
	# var mirror_normal: Vector3 = result["normal"]
	var mirror_normal = hit_normal
	# var mirror_position = collider.global_position
	# realign to center

	var mirror_dot = mirror_normal.dot(direction)
	if mirror_dot != 0:
		var outgoing_direction = direction - 2 * mirror_dot * mirror_normal

		create_beam(rgb, plane_position, outgoing_direction, index+1)

func do_refract(rgb: int, collider, _hit_position: Vector3, direction: Vector3, hit_normal: Vector3, index: int) -> void:
	var prism: Prism = collider.get_node("Prism")

	var prism_position = collider.global_position
	# realign to center
	# var hit_position = prism_position

	# print(direction)
	# print(hit_normal)
	var internal_direction = snells_law(direction, -hit_normal, 1.0 / prism.refraction_index)
	if !internal_direction.is_zero_approx():
		# print("internal_direction: ")
		# print(internal_direction)

		var closest_outgoing_normal = null
		var closest_outgoing_dot = 0

		var prism_normals = prism.get_normals()
		for prism_normal in prism_normals:
			prism_normal = prism.transform.basis * prism_normal
			var hit_dot = prism_normal.dot(hit_normal)
			var internal_dot = prism_normal.dot(internal_direction)
			if hit_dot >= 1.0 - epsilon:
				continue # this is the hit side
			elif abs(prism_normal.y) > epsilon:
				continue # ignore non xz-plane sides
			elif internal_dot > 0:
				if internal_dot > closest_outgoing_dot:
					closest_outgoing_dot = internal_dot
					closest_outgoing_normal = prism_normal

		if closest_outgoing_normal != null:
			# print("closest_outgoing_normal: ")
			# print(closest_outgoing_normal)
			var outgoing_direction = snells_law(internal_direction, closest_outgoing_normal, prism.refraction_index / 1.0)
			if !outgoing_direction.is_zero_approx():
				# print("outgoing_direction: ")
				# print(outgoing_direction)

				create_beam(rgb, prism_position, outgoing_direction, index+1)


# https://physics.stackexchange.com/questions/435512/snells-law-in-vector-form
func snells_law(incoming: Vector3, normal: Vector3, mu: float) -> Vector3:
	var dot = incoming.dot(normal)
	var in_sqrt = 1 - mu*mu * (1-dot*dot)
	if in_sqrt < 0:
		return Vector3.ZERO
	return sqrt(in_sqrt) * normal + mu * (incoming - dot * normal)


func ray_plane_hit(ray_origin, ray_direction, mirror_normal, mirror_distance) -> Vector3:
	var t = -(ray_origin.dot(mirror_normal) + mirror_distance) / ray_direction.dot(mirror_normal)
	return ray_origin + t * ray_direction


func cast_ray(origin: Vector3, end: Vector3) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	# var cam = $Camera3D
	# var mousepos = get_viewport().get_mouse_position()

	# var origin = cam.project_ray_origin(mousepos)
	# var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self]
	query.collide_with_areas = true
	query.collision_mask = 3

	var result = space_state.intersect_ray(query)

	return result
