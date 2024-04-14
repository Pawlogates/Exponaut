extends Container

func _on_visible_on_screen_notifier_2d_screen_exited():
	%water_top.visible = false

func _on_visible_on_screen_notifier_2d_screen_entered():
	%water_top.visible = true
