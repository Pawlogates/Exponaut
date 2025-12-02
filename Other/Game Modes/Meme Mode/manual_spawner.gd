extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LMB"):
		var meme_spawner = preload("res://Meme Mode/memeMode_image_spawner.tscn").instantiate()
		meme_spawner.randomize_all = true
		meme_spawner.position = get_global_mouse_position()
		get_parent().add_child(meme_spawner)
	
	elif Input.is_action_just_pressed("RMB"):
		var meme_spawner2 = preload("res://Meme Mode/memeMode_secondary_spawner.tscn").instantiate()
		meme_spawner2.randomize_all = true
		meme_spawner2.position = get_global_mouse_position()
		get_parent().add_child(meme_spawner2)
