extends CenterContainer

var levelSet_id = Globals.levelSet_id

var levelSet_saved : Array # The saved (in the "SaveData" global node, and the "levelSet" save files) array of best results for each category achieved by the player.
var levelSet_info : Array
var levelSet_unlock : Array

@onready var level_info_container: Control = %level_info_container
@onready var background: TextureRect = %background

# Called when the node enters the scene tree for the first time.
func _ready():
	Overlay.animation("fade_black", false, true, 1.0)
	
	if not levelSet_id == "none":
		levelSet_saved = SaveData.get("saved_" + levelSet_id)
		levelSet_info = SaveData.get("info_" + levelSet_id)
		levelSet_unlock = SaveData.get("unlock_" + levelSet_id)
	
	SaveData.load_levelSet(Globals.l_levelSet_id)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if levelSet_id != "none":
		place_level_icons(levelSet_id)
		background.texture = load(levelSet_info[5])
		level_info_container.get_child(0).grab_focus()
	
	await get_tree().create_timer(0.1, false).timeout
	
	var x = 0
	for button in get_tree().get_nodes_in_group("buttons_root") + get_tree().get_nodes_in_group("buttons_deco"):
		button.z_index = x
		x += 1
	
	for button in get_tree().get_nodes_in_group("buttons"):
		button.moving = true
	
	
	Globals.levelSet_loaded.emit()


func _on_enable_score_attack_mode_pressed():
	if Globals.mode_scoreAttack == false:
		Globals.mode_scoreAttack = true
		$"menu_main/menu_container/Control/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Disable Score Attack Mode[/wave]"
		
	elif Globals.mode_scoreAttack == true:
		Globals.mode_scoreAttack = false
		$"menu_main/menu_container/Control/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Enable Score Attack Mode[/wave]"


func _on_main_menu_pressed():
	if check_if_buttons_blocked():
		return
	
	await Overlay.animation("fade_black", false, true, 1)
	get_tree().change_scene_to_packed(Globals.scene_menu_start)


func _on_back_to_overworld_pressed():
	if check_if_buttons_blocked():
		return
	
	var saved_level = load(SaveData.saved_last_area_filePath)
	
	#DEBUG
	if saved_level == load("res://Levels/empty.tscn"):
		saved_level = load("res://Levels/overworld_infected_glades.tscn")
	
	Overlay.animation("fade_black", true, true, 1)
	Globals.transitioned = false
	get_tree().change_scene_to_packed(saved_level)


var buttons_blocked = false
func check_if_buttons_blocked():
	if buttons_blocked:
		Globals.message_debug("Buttons are blocked.")
		return true
	buttons_blocked = true

func _on_buttons_blocked_timeout() -> void:
	Globals.message_debug("Button are no longer blocked.")
	buttons_blocked = false


func place_level_icons(levelSet_id):
	var level_number = 0
	for icon in range(1, SaveData.get("info_" + levelSet_id)[1]):
		level_number += 1
		print(level_number)
		
		var level_icon = Globals.scene_levelSet_level_icon.instantiate()
		level_icon.level_number = level_number
		$level_icon_container.add_child(level_icon)
