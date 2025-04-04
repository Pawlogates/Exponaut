extends Node2D

@onready var scene_extend_deco = preload("res://Other/Scenes/Random Decoration/random_decoration_column.tscn")

@onready var platform = $platform
@onready var deco_platform = $platform/deco_platform
@onready var deco_floor = $deco_floor

@onready var world = $/root/World
@onready var player = $/root/World.player

@export var extend_on_hit = true
@export var extend_height = 256
@export var extend_on_switch_signal = false
@export var switch_signal_await = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.switch_signal_activated.connect(on_switch_signal_activated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func extend_platform():
	platform.position = Vector2(0, 0)
	var height = extend_height / 4
	var until_spawn_extend_deco = 4
	for pixel in height:
		await get_tree().create_timer(0.025, false).timeout
		height -= 4
		
		platform.position.y -= 4
		
		until_spawn_extend_deco -= 1
		if until_spawn_extend_deco <= 0:
			until_spawn_extend_deco = 4
			var extend_deco = scene_extend_deco.instantiate()
			extend_deco.position = platform.position
			add_child(extend_deco)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not extend_on_hit:
		return
	
	if body.is_in_group("player_projectile") or body.is_in_group("projectile"):
		extend_platform()


func on_switch_signal_activated(switch_signal_ID):
	if not extend_on_switch_signal:
		return
	
	if switch_signal_ID == switch_signal_await:
		extend_platform()
