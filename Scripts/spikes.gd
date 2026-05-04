extends Area2D

@export var damage_value : int = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_entered(area):
	if not Globals.is_valid_entity(area) : return
	
	var target : Node = area.get_parent()
	
	target.handle_damage(-damage_value, self)
