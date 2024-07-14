extends Area2D

@export var damageValue = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_entered(area):
	if area.is_in_group("player"):
		if damageValue == 1:
			Globals.playerHit1.emit()
		elif damageValue == 2:
			Globals.playerHit2.emit()
		elif damageValue == 3:
			Globals.playerHit3.emit()
