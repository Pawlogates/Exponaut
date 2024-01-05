extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.text = str("Total Score: ", Globals.total_score)
