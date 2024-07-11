extends Node2D

var pressed = false
@export var button_type = "none"

func _ready():
	if button_type == "reset_blue" or button_type == "reset_green" or button_type == "reset_red":
		pressed = true
	
	if pressed:
		%AnimationPlayer.play("button_pressed_DOWN")
		if not button_type == "reset_blue" and not button_type == "reset_green" and not button_type == "reset_red":
			%Timer.start()
	
	else:
		%AnimationPlayer.play("button_back_DOWN")


func _on_area_2d_area_entered(area):
	if not pressed and area.is_in_group("player_exact") and not area.get_parent().is_in_group("weightless"):
		pressed = true
		%sound_buttonPressed.play()
		%AnimationPlayer.play("button_pressed_DOWN")
		print("Button pressed: " + str(button_type))
		
		if not button_type == "reset_blue" and not button_type == "reset_green" and not button_type == "reset_red":
			%Timer.start()
		
		
		if button_type == "blue":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "blueButton_pressed")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button", "blueButton_pressALL")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_blue", "reset_button")
		
		if button_type == "reset_blue":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "blueButton_back")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_blue", "reset_button")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_blue", "press_button")
		
		if button_type == "green":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "greenButton_pressed")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button", "greenButton_pressALL")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_green", "reset_button")
		
		if button_type == "reset_green":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "greenButton_back")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_green", "reset_button")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_green", "press_button")
		
		if button_type == "red":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "redButton_pressed")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button", "redButton_pressALL")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_red", "reset_button")
		
		if button_type == "reset_red":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "redButton_back")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_red", "reset_button")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_red", "press_button")
		
		
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "key", "on_button_press")


func _on_timer_timeout():
	%AnimationPlayer.play("button_back_DOWN")
	
	if button_type == "blue":
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "blueButton_back")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_blue", "press_button")
	
	if button_type == "green":
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "greenButton_back")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_green", "press_button")
	
	if button_type == "red":
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "redButton_back")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "resetButton_red", "press_button")
	
	
	await get_tree().create_timer(1, false).timeout
	pressed = false


func blueButton_pressALL():
	if button_type == "blue" and not pressed:
		%AnimationPlayer.play("button_pressed_DOWN")
		pressed = true
		%Timer.start()


func greenButton_pressALL():
	if button_type == "green" and not pressed:
		%AnimationPlayer.play("button_pressed_DOWN")
		pressed = true
		%Timer.start()


func redButton_pressALL():
	if button_type == "red" and not pressed:
		%AnimationPlayer.play("button_pressed_DOWN")
		pressed = true
		%Timer.start()


func reset_button():
	%AnimationPlayer.play("button_back_DOWN")
	%Timer.stop()
	pressed = false


func press_button():
	%AnimationPlayer.play("button_pressed_DOWN")
	pressed = true


#SAVE START
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"pressed" : pressed,
	}
	return save_dict
#!SAVE
