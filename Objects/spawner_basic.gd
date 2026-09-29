extends Node2D

@onready var cooldown_spawn_scene: Timer = $cooldown_spawn_scene
@onready var scan_visible: VisibleOnScreenNotifier2D = $scan_visible


@export_file("*.tscn") var scene_filepath : String = "random"
@export var scene_filepath_keywords : Array = ["none"]

@export var add_position_range : Array = [Vector2(-32, -16), Vector2(32, 0)]
@export var add_scale_range : Array = [Vector2(-0.1, -0.1), Vector2(0.1, 0.1)]
@export var add_scale_equal : bool = true

@export var on_timeout_spawn_scene : bool = true
@export var on_timeout_spawn_scene_chance : float = 100.0
@export var on_timeout_spawn_scene_quantity : int = 1
@export var on_timeout_spawn_scene_quantity_range : Array = [1, 4] # Will be ignored if set to [-1, -1].
@export var on_timeout_set_cooldown : float = 1.0
@export var on_timeout_set_cooldown_range : Array = [0.25, 2.0]

@export var add_modulate : Color = Color(0, 0, 0, 0)
@export var add_modulate_base : Color = Color.WHITE
@export var add_modulate_variance : float = 0.1

@export var add_z_index : int = 1

@export var cooldown_delete : float = 8.0

@export var randomize_scene : int = false

var master_node : Node = self
var number_spawned : int = 0

func _ready() -> void:
	master_node = get_parent()
	restart_cooldown_spawn_scene()

func _on_cooldown_spawn_scene_timeout() -> void:
	if Globals.get_random_bool(on_timeout_spawn_scene_chance):
		spawn_scene()
	
	restart_cooldown_spawn_scene()

func restart_cooldown_spawn_scene():
	if on_timeout_set_cooldown_range != [-1, -1] : cooldown_spawn_scene.wait_time = randf_range(on_timeout_set_cooldown_range[0], on_timeout_set_cooldown_range[1])
	cooldown_spawn_scene.start()

func spawn_scene():
	if not number_spawned: # If spawned a scene 0 times so far.
		if scene_filepath == "random" : randomize_scene = true
	
	if randomize_scene : scene_filepath = "res://Other/Particles/" + Globals.get_files("res://Other/Particles").pick_random()
	
	var new_scenes : Array = await Globals.spawn_scenes(Globals.World, scene_filepath, 1, master_node.position + position, cooldown_delete, add_modulate, Vector2(0, 0), add_z_index, [], [], Vector2(0, 0), [Vector2(0, 0), Vector2(0, 0)], add_position_range, add_scale_range, true, 0, [0.0, 0.1], self)
	for new_scene in new_scenes:
		if add_scale_equal : new_scene.scale.y = new_scene.scale.x
		if add_modulate_base != Color.WHITE : new_scene.modulate = add_modulate_base
		if add_modulate != Color(0, 0, 0, 0) : new_scene.modulate += add_modulate
		if add_modulate_variance:
			var new_scene_modulate : Color = new_scene.modulate
			new_scene.modulate += Color(randf_range(-add_modulate_variance, add_modulate_variance), randf_range(-add_modulate_variance, add_modulate_variance), randf_range(-add_modulate_variance, add_modulate_variance), 0)
	
	number_spawned += 1

func _on_scan_visible_screen_entered() -> void:
	Globals.set_nodes(self, Timer, true)

func _on_scan_visible_screen_exited() -> void:
	Globals.set_nodes(self, Timer, false)
