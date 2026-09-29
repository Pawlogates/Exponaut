extends Node2D

const scene = preload("res://Other/Scenes/User Interface/HUD/HUD.tscn")


func _ready() -> void:
	Globals.main_scene_changed.connect(check)


func check():
	await Globals.await_timer(0.5)
	if Globals.gameState_justStarted : await Globals.await_timer(1.25)
	
	if Globals.gameState_levelSet_screen or Globals.gameState_start_screen:
		if not len(get_tree().get_nodes_in_group("HUD")) : return
		
		if not Globals.gameState_justStarted : Overlay.HUD.animation_player.play("hide")
	
	if Globals.gameState_level or Globals.gameState_tetronaut or not "level_type" in Globals.main_scene:
		if len(get_tree().get_nodes_in_group("HUD")) : return
		
		var instance = scene.instantiate()
		Overlay.add_child(instance)
		Overlay.reassign_general()
		Globals.dm("Added a HUD to the scene tree.")


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("alt") and Input.is_action_just_pressed("3"):
		check()
