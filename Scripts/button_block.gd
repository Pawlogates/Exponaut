extends Node2D

@export var blockType = "none"
@export var blockDirection = -1

var activated = false

#PRESSED
func greenButton_pressed():
	if blockType == "green":
		activated = true
		if blockDirection == 0:
			%AnimationPlayer.play("green_move_left")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("green_move_right")

func blueButton_pressed():
	if blockType == "blue":
		activated = true
		if blockDirection == 0:
			%AnimationPlayer.play("blue_move_up")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("blue_move_down")

func redButton_pressed():
	if blockType == "red":
		activated = true
		%AnimationPlayer.play("red_disable")


#BACK
func blueButton_back():
	if blockType == "blue":
		activated = false
		if blockDirection == 0:
			%AnimationPlayer.play("blue_back_up")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("blue_back_down")

func greenButton_back():
	if blockType == "green":
		activated = false
		if blockDirection == 0:
			%AnimationPlayer.play("green_back_left")
		
		elif blockDirection == 1:
			%AnimationPlayer.play("green_back_right")

func redButton_back():
	if blockType == "red":
		activated = false
		%AnimationPlayer.play("red_enable")


func _ready():
	if activated:
		if blockType == "green":
			if blockDirection == 0:
				%AnimationPlayer.play("green_move_left")
			
			elif blockDirection == 1:
				%AnimationPlayer.play("green_move_right")
		
		elif blockType == "blue":
			if blockDirection == 0:
				%AnimationPlayer.play("blue_move_up")
			
			elif blockDirection == 1:
				%AnimationPlayer.play("blue_move_down")
		
		elif blockType == "red":
			%AnimationPlayer.play("red_disable")
	
	else:
		if blockType == "blue":
			if blockDirection == 0:
				%AnimationPlayer.play("blue_back_up")
			
			elif blockDirection == 1:
				%AnimationPlayer.play("blue_back_down")
		
		elif blockType == "green":
			if blockDirection == 0:
				%AnimationPlayer.play("green_back_left")
			
			elif blockDirection == 1:
				%AnimationPlayer.play("green_back_right")
		
		elif blockType == "red":
			%AnimationPlayer.play("red_enable")


#SAVE START
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"activated" : activated,
	}
	return save_dict
#!SAVE
