extends Node2D

@onready var spawn: Marker2D = $Spawn
@onready var audio_player = $AudioStreamPlayer
@onready var platforms = $Platforms
@export var platform_scene: PackedScene
@export var moved_platform_scene: PackedScene
@export var slippery_platform_scene: PackedScene
@export var offscreen_distance: float = 300
@export var min_gap: float = 150
@export var max_gap: float = 250
@export var min_y: float = 300
@export var max_y: float = 500

var camera: Camera2D
var player: CharacterBody2D
var spawned_platforms: Array[Node] = []

var right_x: float = 0.0
var left_x: float = 0.0

var min_min_gap = 200
var max_max_gap = 500

var all_platforms = 0

func _ready() -> void:
	audio_player.play()
	
	if platform_scene:
		_spawn_platform(spawn.global_position.x, "general") 
	

func _process(delta):
	print("Platforms: ", spawned_platforms.size())

	
	if not camera or not player or not platform_scene:
		return
		
	var screen_size = get_viewport_rect().size
	var camera_position = camera.global_position
	var half_w = screen_size.x / 2
	var left_edge = camera_position.x - half_w
	var right_edge = camera_position.x + half_w
	
	var spawn_type = "general"
	while right_x < right_edge + offscreen_distance:
		var random_num = randi_range(1, 100)
		if random_num < 20:
			spawn_type = "moved"
		elif random_num < 40:
			spawn_type = "slippery"
			
		var current_min_gap = min_gap + all_platforms
		
		var current_max_gap = max_gap + all_platforms
			
		_spawn_platform(right_x + randi_range(current_min_gap, current_max_gap), spawn_type)
		right_x = spawned_platforms[-1].position.x
		all_platforms += 1
	
	for i in range(spawned_platforms.size() - 1, -1, -1):
		var platform = spawned_platforms[i]
		if platform.position.x < left_edge - offscreen_distance:
			platform.queue_free()
			spawned_platforms.remove_at(i)

func _spawn_platform(x: float, platform_type):
	if not platform_scene:
		return
	
	var platform
	if platform_type == "moved":
		platform = moved_platform_scene.instantiate()
	elif platform_type == "slippery":
		platform = slippery_platform_scene.instantiate()
	else:
		platform = platform_scene.instantiate()
		
	platform.position.x = x
	platform.position.y = randi_range(min_y, max_y)
	platforms.add_child(platform)
	spawned_platforms.append(platform)
