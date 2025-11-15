extends Node2D

@onready var staticbox_animation = get_node("Static/StaticBox/AnimationPlayer")
@onready var dude = get_node("PhysicsDude")
@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var menu = $Menu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if menu.visible:
			Global.resume()
			menu.hide()
		else:
			Global.pause()
			menu.show()
			


func _ready() -> void:
	#audio_player.stream = load("res://audio/background.ogg")
	#audio_player.volume_db = linear_to_db(0.5)
	audio_player.play()
	dude.hit.connect(_on_hit_static_box)
	load_settings()
	#Global.pause()


func _on_hit_static_box():
	staticbox_animation.play("hit")
	
	
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
