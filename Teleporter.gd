extends AnimatedSprite2D

#TELEPORTER TYPE MUST BE THE SAME AS ITS GROUP NAME
@export var teleporter_type = "none"
var rng = RandomNumberGenerator.new()


#func _ready():
	#pass

#func _process(delta):
	#pass


var teleport_to_ID = -1

func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("player"):
		Globals.specialAction.emit()
		
		if area.is_in_group("player"):
			teleport_to_ID = int(rng.randi_range (1, get_tree().get_nodes_in_group(teleporter_type).size()))
			for teleporter in get_tree().get_nodes_in_group("teleporter"):
				teleporter.get_node("%Area2D").set_deferred("monitoring", false)
			
			#print(get_tree().get_nodes_in_group(teleporter_type).size())
			#print(str(str(teleporter_type), str(teleport_to_ID)))
			
			for teleporter in get_tree().get_nodes_in_group(str(str(teleporter_type), str(teleport_to_ID))):
				#print(str(str(teleporter_type), str(teleport_to_ID)))
				
				await LevelTransition.fade_to_black_fast()
				area.get_parent().position = teleporter.position
				LevelTransition.fade_from_black()
				
			
			await get_tree().create_timer(2, false).timeout
			for teleporter in get_tree().get_nodes_in_group("teleporter"):
				teleporter.get_node("%Area2D").set_deferred("monitoring", true)
