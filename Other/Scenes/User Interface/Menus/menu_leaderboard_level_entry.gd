extends Control

var recorder_level : Node

@export var target_modulate : Color = Color.WHITE

@onready var menu_bg: Control = $menu_bg


@onready var label_player_name: Label = $container_entry_data/container_main/label_player_name
@onready var label_level_score: Label = $container_entry_data/container_main/label_level_score

@onready var label_level_time: Label = $container_entry_data/container_secondary/label_level_time
@onready var label_damage_taken: Label = $container_entry_data/container_secondary/label_damage_taken
@onready var label_entry_position: Label = $label_entry_position


var player_name : String = "none"
var level_score : float = -1

var level_time : float = -1
var level_damage_taken : float = -1
var entry_position : int = -1

var entry_filepath : String = "none"
var is_unnamed : bool = false
var is_developer : bool = false


func _ready() -> void:
	recorder_level = get_tree().get_first_node_in_group("recorder_level")
	
	update_info()
	
	if is_unnamed : label_player_name.modulate = Color.DARK_RED
	elif is_developer : label_player_name.modulate = Color.WEB_PURPLE
	elif player_name == SaveData.player_name : label_player_name.modulate = Color.GREEN

func _physics_process(delta: float) -> void:
	menu_bg.modulate.a = move_toward(menu_bg.modulate.a, target_modulate.a, delta)
	menu_bg.modulate.r = move_toward(menu_bg.modulate.r, target_modulate.r, delta)
	menu_bg.modulate.g = move_toward(menu_bg.modulate.g, target_modulate.g, delta)
	menu_bg.modulate.b = move_toward(menu_bg.modulate.b, target_modulate.b, delta)


func _on_btn_watch_replay_pressed() -> void:
	if not FileAccess.file_exists(entry_filepath):
		Globals.message("The recording has been deleted (happens during leaderboard refresh...), please refresh the leaderboard and try again.")
		return
	
	get_tree().get_first_node_in_group("leaderboard_level").delete()
	await get_tree().create_timer(1.0, true).timeout
	recorder_level.start_playback(entry_filepath)


func update_info():
	if player_name == "none":
		label_player_name.text = "none (unnamed)"
	else:
		label_player_name.text = str(player_name)
		
	label_level_score.text = str(int(level_score))
	
	label_level_time.text = str(int(level_time / 1000)) + " s"
	label_damage_taken.text = str(level_damage_taken)
	label_entry_position.text = str(entry_position)
