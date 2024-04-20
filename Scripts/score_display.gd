extends Label

var displayScore = 0

func _process(_delta):
	
	if displayScore != Globals.level_score and Globals.level_score - displayScore <= 10:
		displayScore += 1
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore <= 100 and Globals.level_score - displayScore > 10:
		displayScore += 3
	
	if displayScore != Globals.level_score and Globals.level_score - displayScore <= 1000 and Globals.level_score - displayScore > 100:
		displayScore += 11
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore > 1000:
		displayScore += 41
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore > 10000:
		displayScore += 121
		
	if displayScore != Globals.level_score and Globals.level_score - displayScore > 25000:
		displayScore += 251
		
	
	self.text = str(displayScore)
	
	
	
	if Globals.cheated_state == true and not Globals.debug_mode:
		self.text = str("cringe")
		





func _ready():
	Globals.saveState_loaded.connect(score_correct_saved)
	Globals.score_reduced.connect(score_correct)
	Globals.cheated.connect(cheated_replaceScore)
	Globals.scoreReset.connect(reset_displayScore)


func score_correct_saved():
	displayScore = Globals.saved_level_score

func score_correct():
	displayScore = Globals.level_score
	


func cheated_replaceScore():
	Globals.cheated_state = true


func reset_displayScore():
	displayScore = 0
