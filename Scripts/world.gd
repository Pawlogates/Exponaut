extends Node2D

@export var next_level: PackedScene

@onready var canvas_layer = %CanvasLayer


@onready var level_finished = %"Level Finished"



@onready var start_in_container = %StartInContainer
@onready var start_in = %StartIn
@onready var animation_player = %AnimationPlayer

@onready var health_display = %health

var playerStartHP = 50


var levelTime = 0
var start_level_msec = 0.0
@onready var level_timeDisplay = %levelTime

@onready var start_pos = global_position






# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().paused = false
	
	
	
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
	
	RenderingServer.set_default_clear_color(Color.DARK_RED)
	

	#get_tree().paused = true
	
	#start_in_container.visible = true
	start_in_container.visible = false
	
	await LevelTransition.fade_from_black()
	animation_player.play("StartInAnim")
	await animation_player.animation_finished
	#get_tree().paused = false
	
	


func _physics_process(delta):
	levelTime = Time.get_ticks_msec() - start_level_msec
	level_timeDisplay.text = str(levelTime / 1000.0)
	
	if Input.is_action_just_pressed("quicksave"):
		save_game()
		
	if Input.is_action_just_pressed("quickload"):
		load_game()
		Globals.saveState_loaded.emit()
	
	
	if not bg_position_set:
		%bg_previous/CanvasLayer/bg.offset.x = move_toward(%bg_previous/CanvasLayer/bg.offset.x, Globals.bgOffset_target_x, 100 * bgMove_growthSpeed * delta)
		%bg_previous/CanvasLayer/bg.offset.y = move_toward(%bg_previous/CanvasLayer/bg.offset.y, Globals.bgOffset_target_y, 50 * bgMove_growthSpeed * delta)
		bgMove_growthSpeed *= 1.05
		
		if bgMove_started and %bg_previous/CanvasLayer/bg.offset.x == Globals.bgOffset_target_x and %bg_previous/CanvasLayer/bg.offset.y == Globals.bgOffset_target_y:
			bg_position_set = true
			bgMove_growthSpeed = 1
			bgMove_started = false
			
		else:
			bgMove_started = true

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
		print("BG CHANGE STARTED")
		%bg_previous/bg_transition.play("bg_hide")
		
		%bg_current/CanvasLayer/bg/ParallaxLayer/TextureRect.texture = Globals.bgFile_current
		%bg_current/bg_transition.play("bg_show")
		
		%bg_current.name = "bg_TEMP"
		%bg_previous.name = "bg_current"
		%bg_TEMP.name = "bg_previous"
		
		await Globals.bgTransition_finished
		bg_free_to_change = true




var bg_position_set = true
var bgMove_growthSpeed = 1
var bgMove_started = false

func bg_move():
	bg_position_set = false
	


#Save state

func save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
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
		save_game.store_line(json_string)




func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
			
