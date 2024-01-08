extends Node2D

@export var next_level: PackedScene

@onready var canvas_layer = %HUD


@onready var level_finished = %"Level Finished"



@onready var start_in_container = %StartInContainer
@onready var start_in = %StartIn
@onready var animation_player = %AnimationPlayer

@onready var health_display = %health

@export var playerStartHP = 50


var levelTime = 0
var start_level_msec = 0.0
@onready var level_timeDisplay = %levelTime

@onready var start_pos = global_position


@onready var tileset_main = $tileset_main
@onready var tileset_objects = $tileset_objects
@onready var tileset_objects_small = $tileset_objectsSmall






# Called when the node enters the scene tree for the first time.
func _ready():
	#$tileset_objects.queue_free() #DEBUG
	#$tileset_objectsSmall.queue_free() #DEBUG
	get_tree().paused = false
	
	Globals.save.connect(saved_from_outside)
	
	
	
	%HUD.visible = true
	
	tileset_objects.set_layer_enabled(0, true)
	tileset_objects.set_layer_enabled(1, true)
	tileset_objects.set_layer_enabled(2, true)
	tileset_objects.set_layer_enabled(3, true)
	tileset_objects.set_layer_enabled(4, true)
	tileset_objects_small.set_layer_enabled(0, true)
	
	
	Globals.playerHP = playerStartHP
	health_display.text = str(Globals.playerHP)
	start_level_msec = Time.get_ticks_msec()
	
	Globals.playerHit1.connect(reduceHp1)
	Globals.playerHit2.connect(reduceHp2)
	Globals.playerHit3.connect(reduceHp3)
	
	Events.exitReached.connect(exitReached_show_screen)
	
	
	Globals.bgFile_previous = preload("res://Assets/Graphics/bg1.png")
	Globals.bgFile_current = preload("res://Assets/Graphics/bg1.png")
	
	Globals.bgChange_entered.connect(bg_change)
	Globals.bgMove_entered.connect(bg_move)
	
	
	
	if not next_level is PackedScene:
		level_finished.next_level_btn.text = "Results"
		next_level = preload("res://VictoryScreen.tscn")
	
	RenderingServer.set_default_clear_color(Color.SKY_BLUE)
	

	#get_tree().paused = true
	
	#start_in_container.visible = true
	start_in_container.visible = false
	
	await LevelTransition.fade_from_black()
	animation_player.play("StartInAnim")
	await animation_player.animation_finished
	#get_tree().paused = false
	
	




@onready var fps = %fps
@onready var test = %test
@onready var test2 = %test2
@onready var test3 = %test3
@onready var test4 = %test4

var debugToggle = false



var quickLoad_blocked = true

#MAIN START

func _physics_process(delta):
	fps.text = str("fps: ", Engine.get_frames_per_second())
	test.text = str("total persistent objects present: ", Globals.test)
	test2.text = str("total objects queued for next reload: ", Globals.test2)
	test3.text = str("number of people who asked: ", Globals.test3)
	test4.text = str("current active loading zone: ", Globals.test4)
	
	levelTime = Time.get_ticks_msec() - start_level_msec
	level_timeDisplay.text = str(levelTime / 1000.0)
	
	
	if Input.is_action_just_pressed("quicksave") and not quickLoad_blocked:
		quickLoad_blocked = true
		save_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
		
		Globals.test3 = 0 #DEBUG
		
		await get_tree().create_timer(1.0, false).timeout
		Globals.is_saving = false
		
	
	if Input.is_action_just_pressed("quickload") and not quickLoad_blocked:
		quickLoad_blocked = true
		load_game()
		$QuickloadLimiter.start()
		Globals.is_saving = true
		
		Globals.test3 = 0 #DEBUG
		
		await get_tree().create_timer(1.0, false).timeout
		Globals.is_saving = false
	
	
	
	#BACKGROUND MOVEMENT HANDLE
	
	if not bg_position_set:
		%bg_previous/CanvasLayer/bg.offset.x = move_toward(%bg_previous/CanvasLayer/bg.offset.x, Globals.bgOffset_target_x, 100 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg.offset.y = move_toward(%bg_previous/CanvasLayer/bg.offset.y, Globals.bgOffset_target_y, 250 * bgMove_growthSpeed * delta)
		
		%bg_current/CanvasLayer/bg.offset.x = move_toward(%bg_current/CanvasLayer/bg.offset.x, Globals.bgOffset_target_x, 100 * bgMove_growthSpeed * delta)
		%bg_current/CanvasLayer/bg.offset.y = move_toward(%bg_current/CanvasLayer/bg.offset.y, Globals.bgOffset_target_y, 250 * bgMove_growthSpeed * delta)
		bgMove_growthSpeed *= 0.99
		bgMove_growthSpeed = clamp(bgMove_growthSpeed, 0.05, 1)
		
		print(50 * bgMove_growthSpeed * delta)
		
		if bgMove_started and %bg_previous/CanvasLayer/bg.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg.offset.y == Globals.bgOffset_target_y:
			bg_position_set = true
			bgMove_growthSpeed = 1
			bgMove_started = false
			
		else:
			bgMove_started = true
	
	
	
	#DEBUG
	
	if Input.is_action_just_pressed("show_debugInfo"):
		if debugToggle:
			%fps.visible = false
			%test.visible = false
			%test2.visible = false
			%test3.visible = false
			%test4.visible = false
			debugToggle = false
			get_tree().set_debug_collisions_hint(false) 
		
		else:
			%fps.visible = true
			%test.visible = true
			%test2.visible = true
			%test3.visible = true
			%test4.visible = true
			debugToggle = true
			get_tree().set_debug_collisions_hint(true) 
	

#MAIN END





#HANDLE REDUCE PLAYER HP

func reduceHp1():
	Globals.playerHP -= 1
	health_display.text = str(Globals.playerHP)
	if Globals.playerHP <= 0:
		retry()
	

func reduceHp2():
	Globals.playerHP -= 2
	health_display.text = str(Globals.playerHP)
	if Globals.playerHP <= 0:
		retry()

func reduceHp3():
	Globals.playerHP -= 3
	health_display.text = str(Globals.playerHP)
	if Globals.playerHP <= 0:
		retry()



#HANDLE LEVEL EXIT REACHED

func _on_exitReached_next_level():
	Globals.total_score = Globals.total_score + Globals.level_score
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	go_to_next_level()


func _on_exitReached_retry():
	retry()


func exitReached_show_screen():
	level_finished.show()
	level_finished.retry_btn.grab_focus()
	
	get_tree().paused = true
	


func go_to_next_level():
	
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 0
	Globals.collected_in_cycle = 0



func retry():
	
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(scene_file_path)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.playerHP = playerStartHP





#Background change

var bg_free_to_change = true

func bg_change():
	await Globals.bgTransition_finished
	
	if bg_free_to_change:
		bg_free_to_change = false
		#print("BG CHANGE STARTED")
		%bg_previous/bg_transition.play("bg_hide")
		
		%bg_current/CanvasLayer/bg/bg_main/TextureRect.texture = Globals.bgFile_current
		%bg_current/bg_transition.play("bg_show")
		
		%bg_current.name = "bg_TEMP"
		%bg_previous.name = "bg_current"
		%bg_TEMP.name = "bg_previous"
		
		await Globals.bgTransition_finished
		bg_free_to_change = true




var bg_position_set = true
var bgMove_growthSpeed = 0.1
var bgMove_started = false

func bg_move():
	bg_position_set = false
	


#Save state

func save_game():
	if not Globals.is_saving:
		Globals.is_saving = true
		
		var save_gameFile = FileAccess.open("user://savegame.save", FileAccess.WRITE)
		var save_nodes = get_tree().get_nodes_in_group("Persist")
		for node in save_nodes:
			# Check the node is an instanced scene so it can be instanced again during load.
			if node.scene_file_path.is_empty():
				print("persistent node '%s' is not an instanced scene, skipped" % node.name)
				continue
			# Check the node has a save function.
			if !node.has_method("save"):
				print("persistent node '%s' is missing a save() function, skipped" % node.name)
				continue
			# Call the node's save function.
			var node_data = node.call("save")

			# JSON provides a static method to serialized JSON string.
			var json_string = JSON.stringify(node_data)

			# Store the save dictionary as a new line in the save file.
			save_gameFile.store_line(json_string)
			
			
		Globals.saved_player_posX = %Player.position.x
		Globals.saved_player_posY = %Player.position.y
		
		Globals.saved_level_score = Globals.level_score
		Globals.combo_score = 0
		Globals.combo_tier = 1
		Globals.collected_in_cycle = 0
		
		%quicksavedDisplay/Label/AnimationPlayer.play("on_justQuicksaved")
		
		Globals.saveState_saved.emit()
		
		
		await get_tree().create_timer(0.1, false).timeout
		Globals.is_saving = false
	
	




func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		if i.is_in_group(Globals.loadingZone_current) or i.is_in_group("loadingZone0"):
			i.queue_free()

	var save_gameFile = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_gameFile.get_position() < save_gameFile.get_length():
		var json_string = save_gameFile.get_line()

		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.get_data()


		
		if "loadingZone" in node_data and node_data["loadingZone"] == Globals.loadingZone_current or "loadingZone" in node_data and node_data["loadingZone"] == "loadingZone0":
			var new_object = load(node_data["filename"]).instantiate()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
					continue
				new_object.set(i, node_data[i])
			
		else:
			continue
			
		
	%Player.position.x = Globals.saved_player_posX
	%Player.position.y = Globals.saved_player_posY
		
	Globals.level_score = Globals.saved_level_score
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.saveState_loaded.emit()
	





func _on_quickload_limiter_timeout():
	quickLoad_blocked = false
	Globals.test3 = 1 #DEBUG


func saved_from_outside():
	quickLoad_blocked = true
	$QuickloadLimiter.stop()
	await get_tree().create_timer(0.2, false).timeout
	save_game()
	$QuickloadLimiter.start()
	
	Globals.test3 = 0 #DEBUG
