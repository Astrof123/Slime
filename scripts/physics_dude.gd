extends CharacterBody2D

const SPEED = 200.0
const  JUMP_VELOCITY = -400.0
const GRAVITY = 800
const STUN_TIME = 0.5
var is_double_jump = false
var stun_delay = 0
var is_held: bool = false
var interactive = null
const PICKUP_DISTANCE = 100
var crate: RigidBody2D = null
const THROW_FORCE = 400

enum State {IDLE, RUN, JUMP, DOUBLE_JUMP, STUN}

@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("DudeSprite")
@onready var step_player: AudioStreamPlayer = get_node("StepPlayer")
@onready var jump_player: AudioStreamPlayer = get_node("JumpPlayer")
var knockback_velocity = Vector2.ZERO

signal hit


var current_state: State = State.IDLE

func set_state(new_state: State):
	current_state = new_state


func _ready() -> void:
	set_state(State.IDLE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and not is_held:
		var state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		shape.radius = PICKUP_DISTANCE
		query.shape = shape
		query.collide_with_areas = true
		query.transform = Transform2D(0, global_position)
		query.exclude = [self]
		var results = state.intersect_shape(query)
		
		for result in results:
			if "Crate" == result.collider.name:
				crate = result.collider
				crate.hold(self)
				is_held = true
			if result.collider is Area2D:
				interactive = result.collider
	
	if event.is_action_released("pickup"):
		if interactive and interactive.has_method("activate"):
			interactive.activate()
			interactive = null
		elif is_held:
			var direction = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT
			direction.y = -0.5
			crate.release(direction * THROW_FORCE)
			crate = null
			is_held = false
	
func handle_held(delta):
	if crate:
		crate.global_transform.origin = global_position + Vector2(0, -40)
		

func handle_idle(delta):
	animation.play("idle")
	
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x = 0
		#velocity.x = move_toward(velocity.x, 0, SPEED / 40)
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		if not jump_player.playing:
			jump_player.play()
		is_double_jump = true
		set_state(State.JUMP)
	

func handle_run(delta):
	animation.play("run")
	if not step_player.playing:
		step_player.play()
		
	
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		set_state(State.IDLE)
		return
		
	if Input.is_action_just_pressed("jump"):
		if not jump_player.playing:
			jump_player.play()
		velocity.y = JUMP_VELOCITY
		is_double_jump = true
		set_state(State.JUMP)


func handle_jump(delta):
	animation.play("jump")


	if Input.is_action_just_pressed("jump") and is_double_jump:
		velocity.y = JUMP_VELOCITY
		is_double_jump = false
		set_state(State.DOUBLE_JUMP)

	var direction = Input.get_axis("left", "right")
	velocity.x = lerp(velocity.x, direction * SPEED, 0.2)


func handle_double_jump(delta):
	animation.play("double_jump")

	if velocity.y > 0:
		set_state(State.JUMP)


func update_flip():
	sprite.flip_h = velocity.x < 0
	
	
func _physics_process(delta: float) -> void:
	
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.RUN:
			handle_run(delta)
		State.JUMP:
			handle_jump(delta)
		State.DOUBLE_JUMP:
			handle_double_jump(delta)
		State.STUN:
			handle_stun(delta)
			
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, delta * 1000)  # Плавное замедление
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	handle_collisions(delta)
	update_flip()
	move_and_slide()
	handle_held(delta)

	if is_on_floor() and current_state in [State.JUMP, State.DOUBLE_JUMP]:
		if abs(velocity.x) > 0:
			set_state(State.RUN)
		else:
			set_state(State.IDLE)


func handle_collisions(delta):
	var platform = null
	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
				
		if "TrapHit" in collider.name:
			var force = 2
			velocity = normal * SPEED * force
			set_state(State.JUMP)
		if "StaticBox" in collider.name:
			var force = 4
			if normal.y < 0:
				force = 2
			velocity = normal * SPEED * force
			set_state(State.JUMP)
		if "Wall" in collider.name:
			if abs(normal.x) > 0.8:
				velocity = normal * SPEED
				stun_delay = STUN_TIME
				set_state(State.STUN)
		if "Bridge" in collider.name:
			platform = collider
		if "Rock" in collider.name:
			collider.apply_impulse(-normal * 10)
		if "Slime" in collider.name:
			var slime_scale = collider.get_node("CollisionShape2D").scale
			if normal.y < 0 and slime_scale == Vector2(1.0, 1.0):
				var slime_animation = collider.get_node("AnimationPlayer")
				slime_animation.play("hit")
				velocity = normal * SPEED * 2
				set_state(State.JUMP)
			
			
	if Input.is_action_just_pressed("down") and platform != null:
		var collision = platform.get_child(0)
		collision.disabled = true
		await get_tree().create_timer(0.1).timeout
		collision.disabled = false


func handle_stun(delta):
	if stun_delay <= 0:
		set_state(State.IDLE)
	
	stun_delay -= delta


func player():
	pass

func apply_knockback(direction: Vector2):
	if direction == Vector2.ZERO:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	knockback_velocity = direction * 400
	
func take_push(attack_direction):
	apply_knockback(attack_direction)
