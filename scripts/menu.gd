extends Node2D


func _on_resume_button_pressed() -> void:
	Global.resume()
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_h_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus, value)
