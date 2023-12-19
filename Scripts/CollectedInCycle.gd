extends Label


func _process(_delta):
	self.text = str(Globals.collected_in_cycle)
