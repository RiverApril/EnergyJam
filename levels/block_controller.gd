extends Node3D

@onready var anim = $Block/AnimatedSprite3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("can_push")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
