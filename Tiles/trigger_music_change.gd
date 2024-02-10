extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



@export var music_file = preload("res://Assets/Sounds/music/ambience_loop1.mp3")

func _on_area_entered(area):
	if not Globals.mode_scoreAttack:
		if area.name == "Player_hitbox_main" and not %music.stream == music_file:
			%music.stream = music_file
			%music.playing = true
