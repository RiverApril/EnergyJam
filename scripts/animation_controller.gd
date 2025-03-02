extends Node3D

@export var anim_path : NodePath = "Block/AnimatedSprite3D"
@export var anim_name : String = "can_push"
var anim: AnimatedSprite3D = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node(anim_path):
		anim = get_node(anim_path)
		if anim:
			anim.play(anim_name)

func stop_anim():
	if anim:
		if anim.is_playing():
			anim.stop()
		anim.queue_free()
		anim = null
	#else:
	#	print("animated sprite not found")
