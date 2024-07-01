extends Node2D

@export var start_toggle_fade = false

@onready var music_player_main = $music

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_toggle_fade_delay()
	if start_toggle_fade:
		$toggle_fade_delay.start()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fading == "in":
		music_player_main.volume_db = move_toward(music_player_main.volume_db, 0, delta * 2)
	
	elif fading == "out":
		music_player_main.volume_db = move_toward(music_player_main.volume_db, -30, delta * 2)
	
	else:
		pass
	
	print("Current music volume: " + str(music_player_main.volume_db))


var fading = "none" # "in", "out", "none"
func _on_toggle_fade_delay_timeout():
	if fading == "in":
		fading = "out"
	else:
		fading = "in"
	
	print("Current music fade: " + str(fading))
	
	randomize_toggle_fade_delay()
	$toggle_fade_delay.start()


func randomize_toggle_fade_delay():
	var delay = randi_range(1, 120)
	$toggle_fade_delay.wait_time = delay
