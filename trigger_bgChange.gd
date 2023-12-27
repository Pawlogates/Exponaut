extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




@export var Background_filePath = preload("res://Assets/Graphics/bg1.png")

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
		Globals.bgFile_previous = Globals.bgFile_current
		if Globals.bgFile_current != self.Background_filePath:
			
			Globals.bgFile_current = self.Background_filePath
			Globals.bgChange_entered.emit()
