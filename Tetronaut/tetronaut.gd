extends Control

@onready var container_blocks: Control = $container_blocks
@onready var cooldown_spawn_block_chains: Timer = $cooldown_spawn_block_chains

var size_tiles : Vector2 = Vector2(1, 0)
var start_quantity_blocks : int = 12


func _ready() -> void:
	Globals.level_score = 0
	Globals.score_reset.emit()
	
	cooldown_spawn_block_chains.wait_time = randf_range(0.5, 8.0)
	cooldown_spawn_block_chains.start()
	
	Globals.gameState_tetronaut = true
	Globals.reassign_general()
	Globals.set_pause(false)
	
	await Overlay.animation("black_fade_out", 1.0, false, false, 0, false, "res://Other/Scenes/transition_gears.tscn", 2.0, Vector2(-2, 0))
	
	await get_tree().create_timer(1.0, true).timeout
	
	spawn_block_chains()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("9") : spawn_block_chains()
	elif Input.is_action_just_pressed("8") : Engine.time_scale = 8
	elif Input.is_action_just_pressed("7") : get_children().pick_random().queue_free()


var spawned_block_chains : Array
var target_block_chain : Node

func spawn_block_chains():
	for tile in size_tiles.x + randi_range(0, 4):
		spawned_block_chains = await Globals.spawn_scenes(container_blocks, load("res://Tetronaut/block_chain.tscn"), 1, Vector2(64 * randi_range(0, 20), 64 * randi_range(0, 10)), -1, Color(0, 0, 0, 0), Vector2(0, 0))
		target_block_chain = spawned_block_chains[0]
		#target_block_chain = await Globals.spawn_scenes(self, load("res://Tetronaut/block_chain.tscn"), 1, Vector2(randi_range(0, 1200), randi_range(0, 600)), -1, Color(0, 0, 0, 0), Vector2(randf_range(-0.75, 0.0), randf_range(-0.75, 0.0)))
		#Globals.spawn_message_object(str(target_block_chain), Globals.main_scene, Vector2(200, 200))


func _on_cooldown_spawn_block_chains_timeout() -> void:
	if len(container_blocks.get_children()) < 25:
		spawn_block_chains()
	
	cooldown_spawn_block_chains.wait_time = randf_range(1.0, 24.0)
	cooldown_spawn_block_chains.start()
