extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if int($Label.text) != Globals.collected_goldenApples:
		$Label.text = str(Globals.collected_goldenApples)
