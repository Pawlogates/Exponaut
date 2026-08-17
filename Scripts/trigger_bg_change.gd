extends Area2D

var number_activated : int = 0 # The number of times this trigger was touched by a valid entity (the player character's hitbox).
@export var single_use : bool = false

@export var randomize_bg_main : bool = false
@export var randomize_bg_front : bool = false
@export var randomize_bg_front2 : bool = false
@export var randomize_bg_back : bool = false
@export var randomize_bg_back2 : bool = false

@export_file("*.png") var bg_main_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_front_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_front2_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_back_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_back2_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"

@export var bg_main_repeat_y : bool = false
@export var bg_front_repeat_y : bool = false
@export var bg_front2_repeat_y : bool = false
@export var bg_back_repeat_y : bool = false
@export var bg_back2_repeat_y : bool = false

@export_file("*.png") var bg_main_edge_top_filepath : String = "res://Assets/Graphics/backgrounds/bg_edge_black.png"
@export_file("*.png") var bg_front_edge_top_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_front2_edge_top_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_back_edge_top_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"
@export_file("*.png") var bg_back2_edge_top_filepath : String = "res://Assets/Graphics/backgrounds/bg_empty.png"


var dirpath : String = Globals.d_backgrounds + "/"


func _ready():
	if randomize_bg_main:
		if Globals.get_random_bool(10) : bg_main_filepath = dirpath + "bg_empty.png"
		else : bg_main_filepath = dirpath + Globals.get_files(Globals.d_backgrounds, Globals.World.overworld_level_id).pick_random()
	if randomize_bg_front:
		if Globals.get_random_bool(10) : bg_front_filepath = dirpath + "bg_empty.png"
		else : bg_front_filepath = dirpath + Globals.get_files(Globals.d_backgrounds, Globals.World.overworld_level_id).pick_random()
	if randomize_bg_front2:
		if Globals.get_random_bool(10) : bg_front2_filepath = dirpath + "bg_empty.png"
		else : bg_front2_filepath = dirpath + Globals.get_files(Globals.d_backgrounds, Globals.World.overworld_level_id).pick_random()
	if randomize_bg_back:
		if Globals.get_random_bool(10) : bg_back_filepath = dirpath + "bg_empty.png"
		else : bg_back_filepath = dirpath + Globals.get_files(Globals.d_backgrounds, Globals.World.overworld_level_id).pick_random()
	if randomize_bg_back2:
		if Globals.get_random_bool(10) : bg_back2_filepath = dirpath + "bg_empty.png"
		else : bg_back2_filepath = dirpath + Globals.get_files(Globals.d_backgrounds, Globals.World.overworld_level_id).pick_random()

@onready var collision: CollisionShape2D = $collision
@onready var debug_rect: ColorRect = $debug_rect

func _process(delta):
	if Globals.World.level_type == "debug" : debug_rect.visible = true
	else : debug_rect.visible = false

func _on_area_entered(area):
	if not Globals.is_node_valid_player(area) : return
	
	if single_use and number_activated > 0 : return
	number_activated += 1
	
	Globals.dm("A 'bg_change' trigger has been entered by the player. The main layer's filepath is: " + bg_main_filepath, "GREEN")
	Globals.dm("The main layer's repeat is: " + str(bg_main_repeat_y) + " (2160px if true, 0px if false).", "AQUA")
	Globals.dm("The main layer's top edge filepath is: " + str(bg_main_repeat_y) + " (2160px).", "LIGHT_BLUE")
	
	# Texture filepath.
	
	Globals.bg_main_filepath = Globals.get_filepath(bg_main_filepath)
	
	#if bg_front_filepath != Globals.bg_front_filepath:
	Globals.bg_front_filepath = Globals.get_filepath(bg_front_filepath)
	
	#if bg_front2_filepath != Globals.bg_front2_filepath:
	Globals.bg_front2_filepath = Globals.get_filepath(bg_front2_filepath)
	
	#if bg_back_filepath != Globals.bg_back_filepath:
	Globals.bg_back_filepath = Globals.get_filepath(bg_back_filepath)
	
	#if bg_back2_filepath != Globals.bg_back2_filepath:
	Globals.bg_back2_filepath = Globals.get_filepath(bg_back2_filepath)
	
	
	# Layer repeat.
	if bg_main_repeat_y != Globals.bg_main_repeat_y:
		Globals.bg_main_repeat_y = bg_main_repeat_y
	if bg_front_repeat_y != Globals.bg_front_repeat_y:
		Globals.bg_front_repeat_y = bg_front_repeat_y
	if bg_front2_repeat_y != Globals.bg_front2_repeat_y:
		Globals.bg_front2_repeat_y = bg_front2_repeat_y
	if bg_back_repeat_y != Globals.bg_back_repeat_y:
		Globals.bg_back_repeat_y = bg_back_repeat_y
	if bg_back2_repeat_y != Globals.bg_back2_repeat_y:
		Globals.bg_back2_repeat_y = bg_back2_repeat_y
	
	
	# Top edge filepath.
	if bg_main_edge_top_filepath != Globals.bg_main_edge_top_filepath:
		Globals.bg_main_edge_top_filepath = bg_main_edge_top_filepath
	if bg_front_edge_top_filepath != Globals.bg_front_edge_top_filepath:
		Globals.bg_front_edge_top_filepath = bg_front_edge_top_filepath
	if bg_front2_edge_top_filepath != Globals.bg_front2_edge_top_filepath:
		Globals.bg_front2_edge_top_filepath = bg_front2_edge_top_filepath
	if bg_back_edge_top_filepath != Globals.bg_back_edge_top_filepath:
		Globals.bg_back_edge_top_filepath = bg_back_edge_top_filepath
	if bg_back2_edge_top_filepath != Globals.bg_back2_edge_top_filepath:
		Globals.bg_back2_edge_top_filepath = bg_back2_edge_top_filepath
	
	
	Globals.trigger_bg_change_entered.emit()
