extends Control

@onready var label_total_score: Label = $label_total_score
@onready var background: TextureRect = %background


var levelSet_id = Globals.levelSet_id

var levelSet_saved : Array # The saved (in the "SaveData" global node, and the "levelSet" save files) array of best results for each category achieved by the player.
var levelSet_info : Array
var levelSet_unlock : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.gameState_start_screen = false
	Globals.gameState_levelSet_screen = true
	Globals.gameState_level = false
	Globals.gameState_changed.emit()
	
	Overlay.animation("black_fade_out", 1.0, false, false)
	
	if levelSet_id != "none" and levelSet_id != "all":
		SaveData.load_levelSet(Globals.levelSet_id)
	
	print(Globals.levelSet_id)
	
	if levelSet_id != "none":
		if levelSet_id != "all":
			levelSet_saved = SaveData.get("saved_" + levelSet_id)
			levelSet_info = SaveData.get("info_" + levelSet_id)
			levelSet_unlock = SaveData.get("unlock_" + levelSet_id)
		
		place_level_icons(levelSet_id)
		
		if levelSet_id != "all":
			background.texture = load(levelSet_info[5])
			label_total_score.text = str(int(SaveData.get_total_score(levelSet_id)))
		else:
			background.texture = load("res://Assets/Graphics/backgrounds/bg_cosmos_red.png")
			label_total_score.text = "literally every level :pinched_fingers: :ok_hand:"
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	await get_tree().create_timer(0.1, false).timeout
	
	Globals.levelSet_loaded.emit()

func _physics_process(delta: float) -> void:
	pass


func place_level_icons(levelSet_id):
	if levelSet_id == "all":
		for level_filename in Globals.get_files("res://Levels"):
			var level_icon = Globals.scene_levelSet_level_icon.instantiate()
			level_icon.level_number = -1
			level_icon.icon_level_filepath = "res://Levels/" + level_filename
			$level_icon_container.add_child(level_icon)
	
	else:
		for level_number in range(1, SaveData.get("info_" + levelSet_id)[1] + 1):
			var level_icon = Globals.scene_levelSet_level_icon.instantiate()
			level_icon.level_number = level_number
			$level_icon_container.add_child(level_icon)
