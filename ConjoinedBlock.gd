extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#info_transfered.connect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_scan_for_nearby_area_entered(area):
	if area.get_parent().is_in_group("conjoined_block"):
		print("touching")
		area.get_parent().conjoined_ID = conjoined_ID + 1
		area.get_parent().target_height = target_height + 64
		
		info_transfered.emit()
		queue_free()



signal info_transfered

var conjoined_ID = 0
var target_height = 64

func _on_scan_for_player_area_entered(area):
	if area.get_parent().is_in_group("player"):
		pass




func _on_after_coinjoined_check_timeout():
	print(target_height)
	%block_size.shape.size = Vector2(64, target_height)
	%block_visible_size.size = Vector2(64, target_height)
