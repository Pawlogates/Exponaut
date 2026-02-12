extends Node2D

var scene_filepath = Globals.scene_entity_editor


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quickselect"):
		check()


func check():
	if Globals.gameState_levelSet_screen or Globals.gameState_start_screen:
		if not len(get_tree().get_nodes_in_group("entity_editor")) : return
		if not has_node("./" + "entity_editor") : return
		
		Overlay.HUD.animation_player.play("hide")
	
	if Globals.gameState_level:
		if len(get_tree().get_nodes_in_group("entity_editor")) : return
		if has_node("./" + "entity_editor") : return
		var instance = load(scene_filepath).instantiate()
		Overlay.add_child(instance)
		Overlay.reassign_general()
		Globals.dm("Added an entity_editor to the scene tree.")
