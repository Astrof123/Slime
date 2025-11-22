extends StaticBody2D

@onready var animations: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$AnimationPlayer.play("moving")
