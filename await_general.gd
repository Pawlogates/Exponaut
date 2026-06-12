extends Node2D

@export_file("*.tscn") var scene_filepath : String = "none"
@export var node_group_name : String = "none"

@export var on_action_name_spawn : String = "none"
var on_action_spawn : bool = false
@export var on_action_name_delete : String = "none"
var on_action_delete : bool = false
@export var on_signal_name_spawn : String = "none"
var on_signal_spawn : bool = false
@export var on_signal_name_delete : String = "none"
var on_signal_delete : bool = false
@export var on_gameState_list_name_spawn : Array = ["none"]
var on_gameState_spawn : bool = false
@export var on_gameState_list_name_delete : Array = ["none"]
var on_gameState_delete : bool = false

@export var spawn_if_repeat : bool = false
@export var on_spawn_delete_all_repeats : bool = true


func _ready() -> void:
	set_physics_process(false)
	
	if on_action_name_spawn != "none" or on_action_name_delete != "none":
		on_action_spawn = true
		set_physics_process(true)
	
	if on_action_name_delete != "none":
		on_action_delete = true
	
	if on_signal_name_spawn != "none":
		on_signal_spawn = true
		Globals.get(on_signal_name_spawn).connect(spawn_scene)
	
	if on_signal_name_delete != "none":
		on_signal_delete = true
	
	if on_signal_name_delete != "none":
		on_signal_delete = true
	
	if on_gameState_list_name_spawn != ["none"]:
		Globals.gameState_changed.connect(on_gameState_changed)
		on_gameState_spawn = true
	
	if on_gameState_list_name_delete != ["none"]:
		Globals.gameState_changed.connect(on_gameState_changed)
		on_gameState_delete = true

func _physics_process(delta: float) -> void:
	if on_action_spawn:
		if Input.is_action_just_pressed(on_action_name_spawn):
			spawn_scene()
	
	if on_action_delete:
		if Input.is_action_just_pressed(on_action_name_delete):
				delete_scene()


func spawn_scene():
	if not spawn_if_repeat:
		if len(get_tree().get_nodes_in_group(node_group_name)) > 0:
			return
	
	if on_spawn_delete_all_repeats : await delete_all_repeats() # Because of variable delay.
	
	var scene = load(scene_filepath).instantiate()
	Overlay.add_child(scene)

func delete_all_repeats():
	await get_tree().create_timer(randf_range(0.05, 0.25), true).timeout
	if not is_instance_valid(self) : return
	
	for node in get_tree().get_nodes_in_group(node_group_name):
		node.delete()

func delete_scene():
	for node in get_tree().get_nodes_in_group(node_group_name):
		node.delete()

func on_gameState_changed():
	await get_tree().create_timer(0.4, true).timeout
	
	for gameState in on_gameState_list_name_spawn:
		if "gameState_" + gameState in Globals:
			if Globals.get("gameState_" + gameState):
				spawn_scene()
	
	for gameState in on_gameState_list_name_delete:
		if "gameState_" + gameState in Globals:
			if Globals.get("gameState_" + gameState):
				delete_scene()
