extends Node2D

var current_level: Node2D = null
var levels: Dictionary = {
	"Training": preload("res://scenes/training_level.tscn"),
	"Infinity": preload("res://scenes/infinity.tscn")
}

var player = null
var camera = null
@onready var player_scene = preload("res://scenes/physics_dude.tscn")
@onready var world = $World


@onready var menu = $UI/Menu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if menu.visible:
			Global.resume()
			menu.hide()
		else:
			Global.pause()
			menu.show()
			


func _ready() -> void:
	player = player_scene.instantiate()
	camera = player.get_node("Camera2D")
	world.add_child(player)
	menu.update_levels(levels.keys())
	load_level(levels.keys()[0])
	menu.level_changed.connect(load_level)
	load_settings()


func load_level(name):
	if current_level:
		current_level.queue_free()
	current_level = levels[name].instantiate()
	player.global_position = current_level.get_node("Spawn").global_position
	world.add_child(current_level)
	match name:
		"Training": 
			camera.enabled = false
		"Infinity": 
			camera.enabled = true
			camera.limit_left = 0
			camera.limit_bottom = 648
			camera.limit_top = 0
	
	
func save_settings():
	var config = ConfigFile.new()
	var slider: HSlider = menu.get_node("CenterContainer/VBoxContainer/HBoxContainer/HSlider")
	config.set_value("audio", "volume", slider.value)
	config.save("user://dude.cfg")
	

func load_settings():
	var config = ConfigFile.new()
	
	var error = config.load("user://dude/cfg")
	
	if error == OK:
		var slider: HSlider = menu.get_node("CenterContainer/VBoxContainer/HBoxContainer/HSlider")
		var volume = config.get_value("audio", "volume", 0.8)
		slider.value = volume
