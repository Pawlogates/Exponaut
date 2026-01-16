extends Node2D

const scene = preload("res://Other/Scenes/User Interface/HUD/HUD.tscn")

func _on_cooldown_refresh_timeout() -> void:
	if Globals.gameState_levelSet:
		if has_node("../" + "HUD") : return
		
		Overlay.HUD.active = false
		Overlay.HUD.animation_player.play("hide")
	
	if Globals.gameState_level:
		if not has_node("../" + "HUD") : return
		
		Overlay.HUD.active = true
		Overlay.HUD.animation_player.play("show")
		
		var instance = scene.instantiate()
		Overlay.add_child(instance)
