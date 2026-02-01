extends Node2D

const scene = preload("res://Other/Scenes/User Interface/HUD/HUD.tscn")


func _ready() -> void:
	Globals.gameState_changed.connect(check)


func check():
	if Globals.gameState_levelSet_screen or Globals.gameState_start_screen:
		if len(get_tree().get_nodes_in_group("HUD")) : return
		if not has_node("./" + "HUD") : return
		
		Overlay.HUD.animation_player.play("hide")
	
	if Globals.gameState_level:
		if not len(get_tree().get_nodes_in_group("HUD")) : return
		if has_node("./" + "HUD") : return
		
		var instance = scene.instantiate()
		Overlay.add_child(instance)
		Overlay.reassign_general()
		Globals.dm("Added a HUD to the scene tree.")
