extends CanvasLayer

func _ready() -> void:
	Globals.HUD_update_general.connect(update_general)
	update_general()

func update_general():
	if Globals.gameState_levelSet : queue_free()
