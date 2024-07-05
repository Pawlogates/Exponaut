extends StaticBody2D

@export var blockType = "none"
@export var blockDirection = -1

#PRESSED
func greenButton_pressed():
	print("Button pressed: " + str(blockType))
	if blockType == "green":
		if blockDirection == 0:
			%AnimationPlayer.play("green_move_left")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("green_move_right")

func blueButton_pressed():
	print("Button pressed: " + str(blockType))
	if blockType == "blue":
		if blockDirection == 0:
			%AnimationPlayer.play("blue_move_up")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("blue_move_down")

func redButton_pressed():
	print("Button pressed: " + str(blockType))
	if blockType == "red":
		%AnimationPlayer.play("red_disable")


#BACK
func blueButton_back():
	if blockType == "blue":
		if blockDirection == 0:
			%AnimationPlayer.play("blue_back_up")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("blue_back_down")

func greenButton_back():
	if blockType == "green":
		if blockDirection == 0:
			%AnimationPlayer.play("green_back_left")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("green_back_right")

func redButton_back():
	if blockType == "red":
		%AnimationPlayer.play("red_enable")
