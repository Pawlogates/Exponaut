extends Area2D

@export_file("*.png") var bg_main_filepath : String = "res://Assets/Graphics/backgrounds/bg_fields.png"
@export_file("*.png") var bg_front_filepath : String = "res://Assets/Graphics/backgrounds/bg_back_fields.png"
@export_file("*.png") var bg_front2_filepath : String = "res://Assets/Graphics/backgrounds/bg_front_fields.png"
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


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_entered(area):
	if not area.is_in_group("player") : return
	Color.AQUA
	Globals.dm("A 'bg_change' trigger has been entered by the player. The main layer's filepath is: " + bg_main_filepath, "BLUE")
	Globals.dm("The main layer's repeat is: " + str(bg_main_repeat_y) + " (2160px if true, 0px if false).", "AQUA")
	Globals.dm("The main layer's top edge filepath is: " + str(bg_main_repeat_y) + " (2160px).", "LIGHT_BLUE")
	
	# Texture filepath.
	if bg_main_filepath != Globals.bg_main_filepath:
		Globals.bg_main_filepath = bg_main_filepath
	
	if bg_front_filepath != Globals.bg_front_filepath:
		Globals.bg_front_filepath = bg_front_filepath
	
	if bg_front2_filepath != Globals.bg_front2_filepath:
		Globals.bg_front2_filepath = bg_front2_filepath
	
	if bg_back_filepath != Globals.bg_back_filepath:
		Globals.bg_back_filepath = bg_back_filepath
	
	if bg_back2_filepath != Globals.bg_back2_filepath:
		Globals.bg_back2_filepath = bg_back2_filepath
	
	
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
