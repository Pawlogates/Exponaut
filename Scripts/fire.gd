extends Area2D


@export var blockType = "none"
@export var blockDirection = -1

var damageValue = 2



func redButton_pressed():
	print(blockType)
	if blockType == "red":
		%AnimationPlayer.play("red_disable")
		monitoring = false
		monitorable = false
	

func redButton_back():
	if blockType == "red":
		%AnimationPlayer.play("red_enable")
		monitoring = true
		monitorable = true





func _on_area_entered(area):
	if area.is_in_group("player"):
		Globals.playerHit2.emit()

