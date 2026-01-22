extends CanvasLayer

@onready var animation_player: AnimationPlayer = $animation_ui

var active = false

func _ready() -> void:
	Globals.HUD_update_general.connect(update_general)
	update_general()

func update_general():
	if Globals.gameState_levelSet_screen : queue_free()


func _on_animation_ui_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		queue_free()
