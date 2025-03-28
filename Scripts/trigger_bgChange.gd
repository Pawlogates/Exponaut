extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


@export var Background_filePath = preload("res://Assets/Graphics/backgrounds/bg_fields.png")
@export var Background_a_filePath = preload("res://Assets/Graphics/backgrounds/bg_a_fields.png")
@export var Background_b_filePath = preload("res://Assets/Graphics/backgrounds/bg_b_fields.png")

func _on_area_entered(area):
	if area.name == "Player_hitbox_main":
		print(Globals.bg_File_current)
		print(self.Background_filePath.resource_path)
		Globals.bg_File_previous = Globals.bg_File_current
		if Globals.bg_File_current != self.Background_filePath.resource_path:
			
			Globals.bg_File_current = self.Background_filePath.resource_path
			Globals.bgChange_entered.emit()
		
		
		Globals.bg_a_File_previous = Globals.bg_a_File_current
		if Globals.bg_a_File_current != self.Background_a_filePath.resource_path:
			
			Globals.bg_a_File_current = self.Background_a_filePath.resource_path
		
		
		Globals.bg_b_File_previous = Globals.bg_b_File_current
		if Globals.bg_b_File_current != self.Background_b_filePath.resource_path:
			
			Globals.bg_b_File_current = self.Background_b_filePath.resource_path
