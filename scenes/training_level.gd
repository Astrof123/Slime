extends Node2D
@onready var audio_player: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready() -> void:
	audio_player.stream = load("res://audio/background.ogg")
	audio_player.play()
