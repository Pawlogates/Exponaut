extends Control

@onready var health_left: Control = %health_left
@onready var health_middle: ColorRect = %health_middle
@onready var health_right: ColorRect = %health_right
@onready var decoration_main: TextureRect = %decoration_main


var health = 100


func _ready() -> void:
	Globals.update_player_health.connect(update_display)
	update_display()

func _physics_process(delta: float) -> void:
	pass


func update_display():
	if health < 84:
		health_middle.visible == false
	
	health_middle.size.x = health * 4 - 84
	
	for segment in health_left.get_children():
		var segment_id = segment.name.replace("segment", "")
		if segment_id < health:
			segment.visible == false
		else:
			segment.visible == true


func _on_button_pressed() -> void:
	health += 1
	Globals.update_player_health.emit()


func _on_button_2_pressed() -> void:
	health -= 1
	Globals.update_player_health.emit()
