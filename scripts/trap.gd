extends StaticBody2D

var is_work = false
@onready var particles = get_node("GPUParticles2D")

func _ready() -> void:
	$AnimationPlayer.play("idle")
	
func _on_hit_body_entered(body: Node2D) -> void:
	if body.has_method("player") and is_work:
		var attack_direction = (body.global_position - global_position).normalized()
		body.take_push(attack_direction);

func _on_touch_fire_body_entered(body: Node2D) -> void:
	if body.has_method("player") and not is_work:
		is_work = true
		particles.emitting = true
		
		$AnimationPlayer.play("fire")
		var attack_direction = (body.global_position - global_position).normalized()
		body.take_push(attack_direction);
		
		await get_tree().create_timer(4).timeout
		is_work = false
		$AnimationPlayer.play("idle")
		particles.emitting = false
