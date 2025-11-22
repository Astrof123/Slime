extends Node2D

@onready var audio_player = $AudioStreamPlayer

func _ready() -> void:
	audio_player.play()
