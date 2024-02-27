extends StaticBody2D



var pressed = false
@export var button_type = "none"


func _on_area_2d_area_entered(area):
	
	if not pressed and area.is_in_group("player_exact") and not area.get_parent().is_in_group("weightless"):
		%AnimationPlayer.play("button_pressed_DOWN")
		%sound_buttonPressed.play()
		pressed = true
		%Timer.start()
		
		if button_type == "blue":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "blueButton_pressed")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button", "blueButton_pressALL")
		
		if button_type == "green":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "greenButton_pressed")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button", "greenButton_pressALL")
		
		if button_type == "red":
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "redButton_pressed")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button", "redButton_pressALL")
	
	
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "key", "on_button_press")




func _on_timer_timeout():
	%AnimationPlayer.play("button_back_DOWN")
	
	if button_type == "blue":
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "blueButton_back")
	
	if button_type == "green":
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "greenButton_back")
	
	if button_type == "red":
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "button_block", "redButton_back")
	
	
	
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
		
