extends Node2D

var enabled = false
var start_toggle_fade = true

@onready var layer1: AudioStreamPlayer = %layer1
@onready var layer2: AudioStreamPlayer = %layer2
@onready var layer3: AudioStreamPlayer = %layer3
@onready var layer4: AudioStreamPlayer = %layer4

@onready var cooldown1: Timer = $layer1/cooldown
@onready var cooldown2: Timer = $layer2/cooldown
@onready var cooldown3: Timer = $layer3/cooldown
@onready var cooldown4: Timer = $layer4/cooldown

@onready var toggle_fade_delay: Timer = $toggle_fade_delay

var print_limit = 100
var print_limit_edge = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.play_music_random.connect(play_music_random)
	
	randomize_toggle_fade_delay()
	
	if start_toggle_fade:
		toggle_fade_delay.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enabled:
		return
	
	var previous_volume = layer1.volume_db
	if fading == "in":
		if layer1.volume_db <= -40:
			layer1.volume_db = move_toward(layer1.volume_db, 0, delta * 2)
		else:
			layer1.volume_db = move_toward(layer1.volume_db, 0, delta * 8)
	
	elif fading == "out":
		if layer1.volume_db <= -40:
			layer1.volume_db = move_toward(layer1.volume_db, -80, delta * 2)
		layer1.volume_db = move_toward(layer1.volume_db, -80, delta * 8)
	
	else:
		pass
	
	
	if layer1.volume_db != previous_volume:
		if print_limit > 0:
			print_limit -= 1
			return
		print("Current music volume: " + str(layer1.volume_db))
		print_limit = 100
	
	elif layer1.volume_db == 0 or layer1.volume_db == -80:
		if not print_limit_edge:
			print_limit_edge = true
			print("Current music volume: " + str(layer1.volume_db))


var fading = "none" # "in", "out", "none"
func _on_toggle_fade_delay_timeout():
	if enabled:
		return
	
	if fading == "in":
		fading = "out"
	else:
		fading = "in"
	
	print("Current music fade: " + str(fading))
	
	randomize_toggle_fade_delay()
	toggle_fade_delay.start()


func randomize_toggle_fade_delay():
	var delay = randi_range(6, 120)
	toggle_fade_delay.wait_time = delay
	print_limit_edge = false


func play_music_random():
	var music_dir_path = "res://Assets/Sounds/music"
	var music_dir = DirAccess.open(music_dir_path)
	var music_list = []
	
	if music_dir != null:
		var filenames = music_dir.get_files()
		
		for filename in filenames:
			if filename.ends_with(".mp3"):
				music_list.append(filename)
	
	var rolled_music = music_list.pick_random()
	print(rolled_music)
	layer1.stream = load(music_dir_path + "/" + rolled_music)
	layer1.play()
