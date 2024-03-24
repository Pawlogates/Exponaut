extends Container

@onready var waterfall = $AnimatedSprite2D


func _on_visible_on_screen_notifier_2d_screen_exited():
	waterfall.visible = false

func _on_visible_on_screen_notifier_2d_screen_entered():
	waterfall.visible = true
