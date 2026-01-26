extends Area2D

@export var bg_filepath : String = "res://Assets/Graphics/backgrounds/bg_fields.png"
@export var bg_front_filepath : String = "res://Assets/Graphics/backgrounds/bg_a_fields.png"
@export var bg_front2_filepath : String = "res://Assets/Graphics/backgrounds/bg_b_fields.png"
@export var bg_back_filepath : String = "res://Assets/Graphics/backgrounds/bg_b_fields.png"
@export var bg_back2_filepath : String = "res://Assets/Graphics/backgrounds/bg_b_fields.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_entered(area):
	if area.name == "player":
		Globals.dm("A 'bg_change' trigger has been entered by the player. The main layer's filepath is: " + bg_filepath)
		Globals.bg_hidden_filepath
		
		if bg_filepath != Globals.bg_visible_filepath:
			Globals.bg_visible_filepath = bg_filepath
		
		if bg_front_filepath != Globals.bg_front_visible_filepath:
			Globals.bg_front_visible_filepath = bg_front_filepath
		
		if bg_front2_filepath != Globals.bg_front2_visible_filepath:
			Globals.bg_front2_visible_filepath = bg_front2_filepath
		
		if bg_back_filepath != Globals.bg_back_visible_filepath:
			Globals.bg_back_visible_filepath = bg_back_filepath
		
		if bg_back2_filepath != Globals.bg_back2_visible_filepath:
			Globals.bg_back2_visible_filepath = bg_back2_filepath
	
	Globals.trigger_bg_change_entered.emit()
