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
@export var is_gradient = false
@export var gradient_filePath = preload("res://Assets/Graphics/other/gradients/gradient_bg_purple_darkPurple.tres")

func _on_area_entered(area):
	if is_gradient:
		Globals.bg_File_current = gradient_filePath.resource_path
		print(gradient_filePath.resource_path)
		Globals.bg_a_File_current = "res://Assets/Graphics/backgrounds/bg_empty_a.png"
		Globals.bg_b_File_current = "res://Assets/Graphics/backgrounds/bg_empty_b.png"
		Globals.bgChange_entered.emit()
		
		return
	
	if area.name == "Player_hitbox_main":
		print(Globals.bg_File_current)
		print(Background_filePath.resource_path)
		
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
