extends Node

@export var health_texture: Texture2D

func _ready() -> void:
	update_health()


func update_health():
	var container: HBoxContainer = get_node("Panel/HBoxContainer")
	
	if container:
		for child in container.get_children():
			child.queue_free()
			
		for i in Global.max_health:
			var health = TextureRect.new()
			health.texture = health_texture
			health.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			container.add_child(health)
