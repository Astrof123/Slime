extends Node2D

signal level_changed(name)


func on_level_changed(value):
	_on_resume_button_pressed()
	var options = $CenterContainer/VBoxContainer/OptionButton
	level_changed.emit(options.get_item_text(value))


func _on_resume_button_pressed() -> void:
	Global.resume()
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_h_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus, value)


func update_levels(levels):
	var options = $CenterContainer/VBoxContainer/OptionButton
	for level in levels:
		options.add_item(level)
