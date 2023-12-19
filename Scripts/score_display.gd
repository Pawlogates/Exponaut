extends Label

var displayScore = 0

func _process(_delta):
	
	if displayScore != Globals.level_score and Globals.level_score - displayScore <= 10:
		displayScore += 1
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore <= 100 and Globals.level_score - displayScore > 10:
		displayScore += 5
	
	if displayScore != Globals.level_score and Globals.level_score - displayScore <= 1000 and Globals.level_score - displayScore > 100:
		displayScore += 15
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore > 1000:
		displayScore += 45
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore > 10000:
		displayScore += 125
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore > 25000:
		displayScore += 250
		
		
	self.text = str(displayScore)
	
	
