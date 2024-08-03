extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@export var bgMove_x = 0
@export var bgMove_y = 0

@export var bg_a_Move_x = 0
@export var bg_a_Move_y = 0

@export var bg_b_Move_x = 0
@export var bg_b_Move_y = 0

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
			Globals.bgMove_entered.emit()
			
			Globals.bgOffset_target_x = bgMove_x
			Globals.bgOffset_target_y = bgMove_y
			
			Globals.bg_a_Offset_target_x = bg_a_Move_x
			Globals.bg_a_Offset_target_y = bg_a_Move_y
			
			Globals.bg_b_Offset_target_x = bg_b_Move_x
			Globals.bg_b_Offset_target_y = bg_b_Move_y
