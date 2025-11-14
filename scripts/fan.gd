extends StaticBody2D

@onready var animation = $AnimationPlayer
@onready var area = get_node("Area2D/CollisionShape2D")
@onready var particles = get_node("GPUParticles2D")
@onready var audio_player: AudioStreamPlayer2D = get_node("FanPlayer")

func turn_on():
	animation.play("on")
	audio_player.volume_db = linear_to_db(2)
	audio_player.play()
	
	area.disabled = false
	particles.emitting = true

func turn_off():
	animation.play("RESET")
	audio_player.stop()
	area.disabled = true
	particles.emitting = false
