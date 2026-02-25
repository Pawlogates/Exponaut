extends Control

var health = 100
var health_max = 100

@onready var health_left: Control = %health_left
@onready var health_middle: ColorRect = %health_middle
@onready var health_right: Control = %health_right
@onready var decoration_main: TextureRect = %decoration_main

@onready var label_hp: Label = $label_hp

@onready var debug_hp_subtract_10: Button = $"debug_hp -"
@onready var debug_hp_add_10: Button = $"debug_hp +"


func _ready() -> void:
	Globals.player_damage.connect(change_health_value)
	Globals.update_player_health.connect(update_display)
	update_display()

func _physics_process(delta: float) -> void:
	pass


func update_display():
	label_hp.text = str(health)
	
	if health < 8:
		health_middle.visible = false
	
	else:
		health_middle.visible = true
	
	health_middle.size.x = health * 2 - 44
	health_middle.size.x = clamp(health_middle.size.x, 0, 100 + 14)
	
	for segment in health_left.get_children():
	
		var segment_id = segment.name.replace("segment", "")
		if int(segment_id) < health:
			segment.visible = true
		else:
			segment.visible = false
	
	for segment in health_right.get_children():
	
		var segment_id = segment.name.replace("segment", "")
		if int(segment_id) < health - 78:
			segment.visible = true
			segment.modulate.b = 1.0 - float(segment_id) * 0.025
			segment.modulate.r = 1.0 - float(segment_id) * -0.025
		else:
			segment.visible = false


# REMEMBER TO ADD RAINBOW2 MATERIAL TO EACH HP SEGMENT WHEN IN MAX COMBO MODE

func _on_debug_hp_add_pressed() -> void:
	for x in range(10):
		health += 1
		Globals.update_player_health.emit()
		await get_tree().create_timer(0.05, false).timeout
		update_display()


func _on_debug_hp_subtract_pressed() -> void:
	for x in range(10):
		health -= 1
		Globals.update_player_health.emit()
		await get_tree().create_timer(0.01, false).timeout
		update_display()


func change_health_value(value : int = 1):
	for x in range(abs(value)):
		if value > 0 : health += 1
		if value < 0 : health -= 1
		await get_tree().create_timer(0.01, false).timeout
		update_display()
		Globals.update_player_health.emit()
	
	Globals.player_health = health


func debug_show():
	$"debug_hp +".visible = true
	$"debug_hp -".visible = true
