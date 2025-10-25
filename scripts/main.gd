extends Node2D

@onready var staticbox_animation = get_node("Static/StaticBox/AnimationPlayer")
@onready var dude = get_node("PhysicsDude")

func _ready() -> void:
	dude.hit.connect(_on_hit_static_box)
	

func _on_hit_static_box():
	staticbox_animation.play("hit")
	
	
