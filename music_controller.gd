extends Node2D

@export var start_toggle_fade = true
var disabled = false

@onready var music_player_main = $music


var print_limit = 100
var print_limit_edge = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_toggle_fade_delay()
	if start_toggle_fade:
		$toggle_fade_delay.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if disabled:
		return
	
	var previous_volume = music_player_main.volume_db
	if fading == "in":
		if music_player_main.volume_db >= -40:
			music_player_main.volume_db = move_toward(music_player_main.volume_db, 0, delta * 2)
		else:
			music_player_main.volume_db = move_toward(music_player_main.volume_db, 0, delta * 8)
	
	elif fading == "out":
		if music_player_main.volume_db >= -40:
			music_player_main.volume_db = move_toward(music_player_main.volume_db, -80, delta * 2)
		music_player_main.volume_db = move_toward(music_player_main.volume_db, -80, delta * 8)
	
	else:
		pass
	
	
	if music_player_main.volume_db != previous_volume:
		if print_limit > 0:
			print_limit -= 1
			return
		print("Current music volume: " + str(music_player_main.volume_db))
		print_limit = 100
	
	elif music_player_main.volume_db == 0 or music_player_main.volume_db == -80:
		if not print_limit_edge:
			print_limit_edge = true
			print("Current music volume: " + str(music_player_main.volume_db))


var fading = "none" # "in", "out", "none"
func _on_toggle_fade_delay_timeout():
	if disabled:
		return
	
	if fading == "in":
		fading = "out"
	else:
		fading = "in"
	
	print("Current music fade: " + str(fading))
	
	randomize_toggle_fade_delay()
	$toggle_fade_delay.start()


func randomize_toggle_fade_delay():
	var delay = randi_range(6, 120)
	$toggle_fade_delay.wait_time = delay
	print_limit_edge = false
