extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass




@export var loadingZone_ID = "loadingZone0"

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
		Globals.loadingZone_current = loadingZone_ID
	
	
