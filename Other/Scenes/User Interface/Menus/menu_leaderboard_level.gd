extends Control

@onready var container_main: VBoxContainer = $container_main_scroll/container_main
@onready var container_top: VBoxContainer = $container_top
@onready var label_leaderboard: Label = $container_top/label_leaderboard
@onready var label_level_name: Label = $container_top/container_top_menu/label_level_name

var level_id : String = "none"
var levelSet_id : String = "none"

var page_number : int = 1

var list_entry_data : Array

var start_pos = Vector2(-1, -1)
var start_scale = Vector2(-1, -1)

var is_ready : bool = false

var entry_filepath : String = "none"
var entry_filedata
var entry_data : Array


var list_entry_filename : Array

var source : String = "online" # "local, local_best, online


func _ready() -> void:
	Globals.dirpath_to_server(Globals.d_recordings_local_best, "leaderboard/upload")
	Globals.server_to_dirpath(Globals.d_recordings_online)
	Globals.message("If your recording is missing, or none are present, please refresh the leaderboard or wait a bit and do.")
	
	Globals.update_main_scene()
	
	if Globals.main_scene != self:
		start_pos = position
		start_scale = scale
		position.x += randi_range(-4000, 4000)
		position.y += randi_range(-4000, 4000)
		scale /= 10
	
	is_ready = true
	
	level_id = Globals.level_id
	levelSet_id = Globals.levelSet_id
	
	update_level_name()
	
	await get_tree().create_timer(2, true).timeout
	
	await create_entries(level_id)
	
	await get_tree().create_timer(1.0, false).timeout
	Globals.update_recordings_best()
	await get_tree().create_timer(2.0, false).timeout
	Globals.dirpath_to_server(Globals.d_recordings_local_best, "leaderboard/upload")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		queue_free()
	
	if Globals.main_scene != self:
		if is_ready:
			position = lerp(position, start_pos, delta * 2)
			scale = lerp(scale, start_scale, delta)
		else:
			position = lerp(position, Vector2(4000, 2000), delta)
			scale = lerp(scale, Vector2(0.2, 0.2), delta)


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


func create_entries(f_level_id : String = "all"):
	Globals.set_nodes(self, Button, false)
	
	var source_dirpath : String = "none"
	
	if source == "local":
		source_dirpath = Globals.d_recordings_local
		list_entry_filename = Globals.get_files(Globals.d_recordings_local)
	elif source == "local_best":
		list_entry_filename = Globals.get_files(Globals.d_recordings_local_best)
		source_dirpath = Globals.d_recordings_local_best
	elif source == "online":
		list_entry_filename = Globals.get_files(Globals.d_recordings_online)
		source_dirpath = Globals.d_recordings_online
	
	if len(list_entry_filename) > 0:
		for entry_filename in list_entry_filename:
			if not f_level_id == "all":
				if not f_level_id in entry_filename : continue
			
			entry_filepath = source_dirpath + "/" + entry_filename
			entry_filedata = Globals.filepath_to_data(entry_filepath)
			if entry_filedata == null : continue
			print(entry_filedata[0])
			entry_data = [entry_filedata[0]["player_name"], entry_filedata[-1]["level_score"], entry_filedata[-1]["level_time"], entry_filedata[-1]["level_damage_taken"], randi_range(1, 999)]
			list_entry_data.append(entry_data)
			entry_create(entry_data)
			if len(container_main.get_children()) < 10:
				await get_tree().create_timer(0.25, true).timeout
			else:
				await get_tree().create_timer(10 / len(container_main.get_children()), true).timeout
	
	else:
		entry_create(["No recordings have been submitted.", -1, -1, -1, -1])
	
	sort_entries("score")
	
	if source == "online":
		await get_tree().create_timer(5, true).timeout
		
	Globals.set_nodes(self, Button, true)

func delete_entries():
	for entry in container_main.get_children():
		entry.queue_free()
		Globals.spawn_scenes(self, Globals.scene_particle_star, 4, entry.position + entry.size / 2 + Vector2(randi_range(-400, 400), 0))
		Globals.spawn_scenes(self, Globals.scene_particle_splash, 4, entry.position + entry.size / 2 + Vector2(randi_range(-200, 200), 0), 4, Color.WHITE, Vector2(0, 0), 25, ["rotation_degrees"], [randi_range(0, 360)])


func _on_btn_change_level_right_pressed() -> void:
	if level_id.ends_with(str(SaveData.get("info_" + levelSet_id)[1])) : Globals.message("Also no.") ; return
	
	level_id = Globals.suffix_increase(level_id, 1)
	refresh_entries(level_id)

func _on_btn_change_level_left_pressed() -> void:
	if level_id.ends_with(str(1)) : Globals.message("No.") ; return
	
	level_id = Globals.suffix_increase(level_id, -1)
	refresh_entries(level_id)


func refresh_entries(f_level_id : String = "all"):
	update_level_name()
	delete_entries()
	await get_tree().create_timer(0.5, true).timeout
	await create_entries(f_level_id)

func update_level_name():
	if level_id != "none":
		label_level_name.text = SaveData.get("info_" + level_id)[0]


func delete():
	is_ready = false
	await get_tree().create_timer(2, true).timeout
	queue_free()


func _on_btn_close_pressed() -> void:
	queue_free()
	Globals.handle_spawn_menu(true)


func sort_entries(type : String = "score"):
	var highest_entry_position : int = 1
	var list_entry : Array = container_main.get_children() # List of entries with position currently not set.
	
	for entry_quantity in container_main.get_children(): # Run through the loop as many times as there are entries in total for the level.
		var highest_level_score : int = 0
		for entry in list_entry:
			if entry.level_score >= highest_level_score:
				highest_level_score = entry.level_score
		
		for entry in list_entry:
			if entry.level_score >= highest_level_score:
				entry.entry_position = highest_entry_position
				container_main.move_child(entry, highest_entry_position)
				entry.update_info()
				list_entry.erase(entry)
				
				highest_entry_position += 1
				continue
	
	for entry in container_main.get_children():
		if entry.entry_position == 1 : entry.target_modulate = Color.GOLD
		elif entry.entry_position == 2 : entry.target_modulate = Color.LIGHT_CYAN
		elif entry.entry_position == 3 : entry.target_modulate = Color.SADDLE_BROWN
		else : entry.target_modulate = Color(1, 1, 1, 1 / float(-1 + len(container_main.get_children())))
