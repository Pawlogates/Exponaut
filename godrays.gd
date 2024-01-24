extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	material = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_entered():
	material = preload("res://Themes/godrays.tres")


func _on_visible_on_screen_notifier_2d_screen_exited():
	material = null
