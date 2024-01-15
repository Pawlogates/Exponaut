extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	if not Globals.cheated_state:
		self.text = str("Total Score: ", Globals.total_score)
	else:
		self.text = str("massive cringe")


