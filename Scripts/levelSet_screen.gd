extends Control

var levelSet_id = Globals.levelSet_id

var levelSet_saved : Array # The saved (in the "SaveData" global node, and the "levelSet" save files) array of best results for each category achieved by the player.
var levelSet_info : Array
var levelSet_unlock : Array

@onready var background: TextureRect = %background

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.gameState_start_screen = false
	Globals.gameState_levelSet_screen = true
	Globals.gameState_level = false
	Globals.gameState_changed.emit()
	
	Overlay.animation("black_fade_out", 1.0, false, false)
	
	SaveData.load_levelSet(Globals.l_levelSet_id)
	
	if levelSet_id != "none":
		levelSet_saved = SaveData.get("saved_" + levelSet_id)
		levelSet_info = SaveData.get("info_" + levelSet_id)
		levelSet_unlock = SaveData.get("unlock_" + levelSet_id)
		
		place_level_icons(levelSet_id)
		
		background.texture = load(levelSet_info[5])
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	await get_tree().create_timer(0.1, false).timeout
	
	Globals.levelSet_loaded.emit()

func _physics_process(delta: float) -> void:
	pass


func place_level_icons(levelSet_id):
	var level_number = 0
	for icon in range(1, SaveData.get("info_" + levelSet_id)[1]):
		level_number += 1
		
		var level_icon = Globals.scene_levelSet_level_icon.instantiate()
		level_icon.level_number = level_number
		$level_icon_container.add_child(level_icon)
