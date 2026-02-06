extends Node2D

@onready var layer1: AudioStreamPlayer = %layer1
@onready var layer2: AudioStreamPlayer = %layer2
@onready var layer3: AudioStreamPlayer = %layer3
@onready var layer4: AudioStreamPlayer = %layer4

@onready var layer1_alt: AudioStreamPlayer = %layer1_alt # Used for smooth music transitions.


@onready var c_all_toggle_fade: Timer = $cooldown_all_toggle_fade

@onready var c_layer1_toggle_fade: Timer = $layer1/cooldown_toggle_fade
@onready var c_layer2_toggle_fade: Timer = $layer2/cooldown_toggle_fade
@onready var c_layer3_toggle_fade: Timer = $layer3/cooldown_toggle_fade
@onready var c_layer4_toggle_fade: Timer = $layer4/cooldown_toggle_fade


@export var enabled = true


# Last music track's filepath - [START]
var layer1_last_filepath = null
var layer2_last_filepath = null
var layer3_last_filepath = null
var layer4_last_filepath = null

var layer1_alt_last_filepath = null
# Last music track's filepath - [END]

var print_limit = 25 # The debug message will be printed only once every 25 calls.

# Is the layer currently playing its music track - [START]
# Note: This was needed to be custom, as reassigning the "stream" property sets the "playing" property to false INSTANTLY, making needed checks impossible to perform, at least in the most intuitive way.
var layer1_is_playing = false
var layer2_is_playing = false
var layer3_is_playing = false
var layer4_is_playing = false

var layer1_alt_is_playing = false
# Is the layer currently playing its music track - [END]


@export_file("*.mp3", "*.wav") var layer1_music_filepath = "res://Assets/Sounds/music/factory5.mp3"
@export_file("*.mp3", "*.wav")  var layer2_music_filepath = "none"
@export_file("*.mp3", "*.wav")  var layer3_music_filepath = "none"
@export_file("*.mp3", "*.wav")  var layer4_music_filepath = "none"

@export var layer1_alt_music_filepath = "none"


# Layer's fade state - [START]
@export var layer1_fade_active : bool = true
@export var layer2_fade_active : bool = false
@export var layer3_fade_active : bool = false
@export var layer4_fade_active : bool = false

@export var layer1_alt_fade_active : bool = false
# Layer's fade state - [END]

# Layer's fade direction - [START]
@export var layer1_fade_direction : int = 1 # States: "1" - fading in, "0" - fading out.
@export var layer2_fade_direction : int = 0
@export var layer3_fade_direction : int = 0
@export var layer4_fade_direction : int = 0

@export var layer1_alt_fade_direction : int = 0
# Layer's fade direction - [END]


@export var cooldown_all_toggle_fade : float = 240.0

@export var cooldown_layer1_toggle_fade : float = 120.0
@export var cooldown_layer2_toggle_fade : float = 120.0
@export var cooldown_layer3_toggle_fade : float = 120.0
@export var cooldown_layer4_toggle_fade : float = 120.0


@export var layer1_max_volume : float = 1.0
@export var layer2_max_volume : float = 1.0
@export var layer3_max_volume : float = 1.0
@export var layer4_max_volume : float = 1.0

@export var layer1_min_volume : float = 0.0
@export var layer2_min_volume : float = 0.0
@export var layer3_min_volume : float = 0.0
@export var layer4_min_volume : float = 0.0


@export var fade_multiplier : float = 1.0


# Randomization:
var random_cooldown_toggle_fade : bool = false
var random_cooldown_fade_range : float = 600.0


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.play_music_random.connect(play_music_random)
	Globals.refreshed0_5.connect(update_is_playing)
	
	layer1.volume_linear = 0.0
	layer1_alt.volume_linear = 0.0
	layer2.volume_linear = 0.0
	layer3.volume_linear = 0.0
	layer4.volume_linear = 0.0
	
	layer1_last_filepath = Globals.get_filepath(layer1.stream)
	layer1_alt_last_filepath = Globals.get_filepath(layer1_alt.stream)
	layer2_last_filepath = Globals.get_filepath(layer2.stream)
	layer3_last_filepath = Globals.get_filepath(layer3.stream)
	layer4_last_filepath = Globals.get_filepath(layer4.stream)
	
	if enabled:
		update_layer_all_music_file()
		layer_play("all", true)
	
	if random_cooldown_toggle_fade:
		randomize_cooldown_toggle_fade("all")
		start_cooldown_toggle_fade("all")


func _process(delta):
	if not enabled : return
	
	Globals.dm("Music layer_1's fade direction: " + str(layer1_fade_direction) + " (" + str(layer1_fade_active) + ").", 1, 0, 0.5)
	Globals.dm("Music layer_1_alt's fade direction: " + str(layer1_alt_fade_direction) + " (" + str(layer1_alt_fade_active) + ").", 2, 0, 0.5)
	Globals.dm("Music layer_1's music track's filepath: " + Globals.get_filepath(layer1_music_filepath, true), 3, 0, 0.5)
	Globals.dm("Music layer_1_alt's music track's filepath: " + Globals.get_filepath(layer1_alt_music_filepath, true), 4, 0, 0.5)
	
	
	if layer1_fade_active : handle_layer1_fade(delta)
	if layer2_fade_active : handle_layer2_fade(delta)
	if layer3_fade_active : handle_layer3_fade(delta)
	if layer4_fade_active : handle_layer4_fade(delta)
	
	if print_limit > 0:
		print_limit -= 1
	
	else:
		Globals.dm("Current main ('1') music layer's volume: " + str(layer1.volume_linear), "PURPLE")
		Globals.dm("Current main ('1_alt') music layer's volume: " + str(layer1_alt.volume_linear), "DARK_MAGENTA")
		
		print_limit = 25
		Globals.dm(str("Message print limit has been reset back to %s." % print_limit))


func toggle_fade(target_id, restart_timer):
	if target_id == "all":
		
		if layer1_fade_active : layer1_fade_active = 0
		else : layer1_fade_active = 1
		if layer2_fade_active : layer2_fade_active = 0
		else : layer2_fade_active = 1
		if layer3_fade_active : layer3_fade_active = 0
		else : layer3_fade_active = 1
		if layer4_fade_active : layer4_fade_active = 0
		else : layer4_fade_active = 1
		
		if restart_timer:
			c_layer1_toggle_fade.start()
			c_layer2_toggle_fade.start()
			c_layer3_toggle_fade.start()
			c_layer4_toggle_fade.start()
	
	else:
		var property_name = str("layer%s_fade_active" % target_id)
		
		if get(property_name) : set(property_name, 0)
		else : set(property_name, 1)

func randomize_cooldown_toggle_fade(target_id : String = "all"):
	if target_id == "all":
		for x in range(1, 5):
			var layer = get_node("layer" + str(x))
			var cooldown_toggle_fade = layer.get_node("cooldown_toggle_fade")
			
			cooldown_toggle_fade.wait_time = randf_range(-random_cooldown_fade_range, random_cooldown_fade_range)
	
	else:
		var layer = get_node("layer" + str(target_id))
		var cooldown_toggle_fade = layer.get_node("cooldown_toggle_fade")
		
		cooldown_toggle_fade.wait_time = randf_range(-random_cooldown_fade_range, random_cooldown_fade_range)

func start_cooldown_toggle_fade(target_id):
	if target_id == "all":
		for x in range(1, 5):
			var layer = get_node("layer" + str(x))
			var cooldown_toggle_fade = layer.get_node("cooldown_toggle_fade")
			
			cooldown_toggle_fade.start()
	
	else:
		var layer = get_node("layer" + str(target_id))
		var cooldown_toggle_fade = layer.get_node("cooldown_toggle_fade")
		
		cooldown_toggle_fade.start()


func play_music_random():
	var music_dir = DirAccess.open(Globals.d_music)
	var list_music = []
	
	if music_dir != null:
		var filenames = music_dir.get_files()
		
		for filename in filenames:
			if filename.ends_with(".mp3"):
				list_music.append(filename)
	
	var rolled_music = list_music.pick_random()
	Globals.dm("Music Manager is applying random music (%s)." % rolled_music)
	layer1.stream = load(Globals.d_music + "/" + rolled_music)
	layer1.play()


func _on_cooldown1_toggle_fade_timeout() -> void:
	if not enabled : return
	
	toggle_fade("1", true)


func _on_cooldown2_toggle_fade_timeout() -> void:
	if not enabled : return
	
	toggle_fade("2", true)


func _on_cooldown3_toggle_fade_timeout() -> void:
	if not enabled : return
	
	toggle_fade("3", true)


func _on_cooldown4_toggle_fade_timeout() -> void:
	if not enabled : return
	
	toggle_fade("4", true)


func _on_cooldown_all_toggle_fade_timeout() -> void:
	if not enabled : return
	
	if random_cooldown_toggle_fade : randomize_cooldown_toggle_fade()
	toggle_fade("all", true)


func handle_layer1_fade(delta):
	layer1.volume_linear = move_toward(layer1.volume_linear, layer1_fade_direction, delta / 5)
	if layer1.volume_linear < layer1_min_volume : layer1.volume_linear = layer1_min_volume
	if layer1.volume_linear > layer1_max_volume : layer1.volume_linear = layer1_max_volume
	
	layer1_alt.volume_linear = move_toward(layer1_alt.volume_linear, layer1_alt_fade_direction, delta / 5)
	if layer1_alt.volume_linear < layer1_min_volume : layer1_alt.volume_linear = layer1_min_volume
	if layer1_alt.volume_linear > layer1_max_volume : layer1_alt.volume_linear = layer1_max_volume

func handle_layer2_fade(delta):
	layer2.volume_linear = move_toward(layer2.volume_linear, layer2_fade_direction, delta)
	if layer2.volume_linear < layer2_min_volume : layer2.volume_linear = layer2_min_volume
	if layer2.volume_linear > layer2_max_volume : layer2.volume_linear = layer2_max_volume

func handle_layer3_fade(delta):
	layer3.volume_linear = move_toward(layer3.volume_linear, layer3_fade_direction, delta)
	if layer3.volume_linear < layer3_min_volume : layer3.volume_linear = layer3_min_volume
	if layer3.volume_linear > layer3_max_volume : layer3.volume_linear = layer3_max_volume

func handle_layer4_fade(delta):
	layer4.volume_linear = move_toward(layer4.volume_linear, layer4_fade_direction, delta)
	if layer4.volume_linear < layer4_min_volume : layer4.volume_linear = layer4_min_volume
	if layer4.volume_linear > layer4_max_volume : layer4.volume_linear = layer4_max_volume


func update_layer_all_music_file():
	if layer1_music_filepath != "none":
		if load(layer1_music_filepath).get_path() != layer1_last_filepath:
			layer1.stream = load(layer1_music_filepath)
	
	if layer1_alt_music_filepath != "none":
		if load(layer1_alt_music_filepath).get_path() != layer1_alt_last_filepath:
			layer1_alt.stream = load(layer1_alt_music_filepath)
	
	if layer2_music_filepath != "none":
		if load(layer2_music_filepath).get_path() != layer2_last_filepath:
			layer2.stream = load(layer2_music_filepath)
	
	if layer3_music_filepath != "none":
		if load(layer3_music_filepath).get_path() != layer3_last_filepath:
			layer3.stream = load(layer3_music_filepath)
	
	if layer4_music_filepath != "none":
		if load(layer4_music_filepath).get_path() != layer4_last_filepath:
			layer4.stream = load(layer4_music_filepath)


func layer_play(target_id : String, interrupt : bool = false):
	if target_id == "all":
		
		if interrupt:
			layer1.play()
			layer1_alt.play()
			layer2.play()
			layer3.play()
			layer4.play()
		
		else:
			if not layer1.playing : layer1.play()
			if not layer1_alt.playing : layer1_alt.play()
			if not layer2.playing : layer2.play()
			if not layer3.playing : layer3.play()
			if not layer4.playing : layer4.play()
	
	
	layer1_last_filepath = Globals.get_filepath(layer1.stream)
	layer1_alt_last_filepath = Globals.get_filepath(layer1_alt.stream)
	layer2_last_filepath = Globals.get_filepath(layer2.stream)
	layer3_last_filepath = Globals.get_filepath(layer3.stream)
	layer4_last_filepath = Globals.get_filepath(layer4.stream)


# Only the first layer can have its music tracks smoothly transition between eachother.
func music_change(filepath, layer_id : String = "1", smooth_transition : bool = true):
	Globals.dm("Changing main music layer's music track file to: " + Globals.get_filepath(filepath, false), "PINK")
	
	var layer = get("layer" + layer_id)
	
	if not smooth_transition or layer_id != "1":
		set("layer" + layer_id + "_music_filepath", filepath)
		update_layer_all_music_file()
		layer_play(layer_id)
	
	if layer1_fade_direction and layer1_alt_fade_direction or not layer1_fade_direction and not layer1_alt_fade_direction:
		layer1_fade_direction = 1
		layer1_alt_fade_direction = 0
	
	else:
		
		if layer1_fade_direction and not layer1_alt_fade_direction:
			layer1_alt_music_filepath = filepath
			update_layer_all_music_file()
			layer1_fade_active = true
			layer1_fade_direction = 0
			layer1_alt_fade_active = true
			layer1_alt_fade_direction = 1
			layer_play("all")
		
		elif layer1_alt_fade_direction and not layer1_fade_direction:
			layer1_music_filepath = filepath
			update_layer_all_music_file()
			layer1_fade_active = true
			layer1_fade_direction = 1
			layer1_alt_fade_active = true
			layer1_alt_fade_direction = 0
			layer_play("all")


# This function should not set anything to "true", as that should be done at the time of reassigning a music track file.
func update_is_playing():
	if not layer1.playing : layer1_is_playing = false
	if not layer1_alt.playing : layer1_alt_is_playing = false
	if not layer2.playing : layer2_is_playing = false
	if not layer3.playing : layer3_is_playing = false
	if not layer4.playing : layer4_is_playing = false
