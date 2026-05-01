extends Control

@onready var container_main: VBoxContainer = $container_main_scroll/container_main


var level_id : String = "none"

var page_number : int = 1

var list_entry_data : Array

var start_pos = Vector2(-1, -1)
var start_scale = Vector2(-1, -1)

var is_ready : bool = false

var entry_filepath : String = "none"
var entry_filedata
var entry_data : Array


func _ready() -> void:
	Globals.update_main_scene()
	
	if Globals.main_scene != self:
		start_pos = position
		start_scale = scale
		position.x += randi_range(-4000, 4000)
		position.y += randi_range(-4000, 4000)
		scale /= 10
	
	is_ready = true
	
	await get_tree().create_timer(2, true).timeout
	
	var list_entry_filename = Globals.get_files(Globals.dirpath_recordings)
	
	if len(list_entry_filename) > 0:
		for entry_filename in list_entry_filename:
			entry_filepath = Globals.dirpath_recordings + "/" + entry_filename
			entry_filedata = Globals.filepath_to_data(entry_filepath)
			entry_data = [entry_filedata[0]["player_name"], entry_filedata[-1]["level_score"], entry_filedata[-1]["level_time"], entry_filedata[-1]["level_damage_taken"], randi_range(1, 999)]
			list_entry_data.append(entry_data)
			entry_create(entry_data)
			if len(container_main.get_children()) < 10:
				await get_tree().create_timer(0.25, true).timeout
			else:
				await get_tree().create_timer(10 / len(container_main.get_children()), true).timeout
	
	else:
		entry_create(["No recordings have been submitted.", -1, -1, -1, -1])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		queue_free()
	
	if Globals.main_scene != self:
		if is_ready:
			position = lerp(position, start_pos, delta * 2)
			scale = lerp(scale, start_scale, delta)


func entry_create(entry_data : Array):
	var entry = load("res://Other/Scenes/User Interface/Menus/menu_leaderboard_level_entry.tscn").instantiate()
	
	entry.entry_filepath = entry_filepath
	
	entry.player_name = entry_data[0]
	entry.level_score = entry_data[1]
	
	entry.level_time = entry_data[2]
	entry.level_damage_taken = entry_data[3]
	entry.entry_position = entry_data[4]
	
	if len(container_main.get_children()) == 0 : entry.target_modulate = Color.GOLD
	elif len(container_main.get_children()) == 1 : entry.target_modulate = Color.LIGHT_CYAN
	elif len(container_main.get_children()) == 2 : entry.target_modulate = Color.SADDLE_BROWN
	else : entry.target_modulate = Color(1, 1, 1, 1 / float(-1 + len(container_main.get_children())))
	
	entry.scale *= 0.4
	
	container_main.add_child(entry)
