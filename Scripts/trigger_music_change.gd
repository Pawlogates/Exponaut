extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


@export var music_file = load("res://Assets/Sounds/ambience/ambience_loop1.mp3")

@export var set_volume = true
@export var volume_db = 0 #0 is the normal volume, -50 is too low to hear (disabled).

@export var set_fade = true
@export_enum("none", "in", "out") var fade_type = "none"
@export var reset_next_fade_delay = true
@export var set_next_fade_delay = true
@export var next_fade_delay = 360
@export var randomize_next_fade_delay = true
@export var range_randomize_next_fade_delay = 90

func _on_area_entered(area):
	print(1)
	if not Globals.mode_scoreAttack:
		
		if not area.name == "Player_hitbox_main":
			return
		if %music.stream == music_file and %music.playing:
			print(2)
			return
		
		%music.stream = music_file
		
		if set_next_fade_delay:
			var delay = next_fade_delay
			if randomize_next_fade_delay:
				delay += randi_range(-range_randomize_next_fade_delay, range_randomize_next_fade_delay)
				$/root/World/"Music Controller"/toggle_fade_delay.wait_time = delay
				
		if reset_next_fade_delay:
			$/root/World/"Music Controller"/toggle_fade_delay.start()
		
		if set_volume:
			%music.volume_db = 0
			$/root/World/"Music Controller".fading = "none"
		
		%music.playing = true
