extends Area2D

#@export var force: Vector2 = Vector2(-20, 0)
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			body.isSlippery = true
