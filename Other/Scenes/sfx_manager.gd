extends Node2D

@onready var sfx: AudioStreamPlayer2D = $sfx
@onready var sfx1: AudioStreamPlayer2D = $sfx1
@onready var sfx2: AudioStreamPlayer2D = $sfx2
@onready var sfx3: AudioStreamPlayer2D = $sfx3
@onready var sfx4: AudioStreamPlayer2D = $sfx4

# As soon as any of these variables are assigned an audio file, the sfx manager will try to use them and clear the variable.
var q_sfx_file : AudioStreamMP3 # Usually only the "sfx" variable is used. Other ones are used if more than one instance of the same file is assigned to the main sfx player, but they can also be assigned audio files directly to create combined sound effects made from fading in and out of sfx1, 2, 3 and 4.
var q_sfx1_file : AudioStreamMP3
var q_sfx2_file : AudioStreamMP3
var q_sfx3_file : AudioStreamMP3
var q_sfx4_file : AudioStreamMP3

# When a fade value is not equal to 0, it will be applied to its sfx player so that its volume approaches either 0 or 1 (or a custom value).
var fade = 0
var fade1 = 0
var fade2 = 0
var fade3 = 0
var fade4 = 0


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	sfx_fade(delta)
	sfx_combined_fade(delta)


func sfx_fade(delta):
	if fade: # Fade is active when it's NOT equal to 0. The value also acts as a speed multiplier.
		if fade > 0: # Fade in.
			sfx.volume_linear = move_toward(sfx.volume_linear, 1, delta * fade)
		elif fade < 0: # Fade out.
			sfx.volume_linear = move_toward(sfx.volume_linear, 0, delta * -fade)

func sfx_play(file, volume, pitch): # Example: sfx_manager.sfx_play(Globals.sfx_player_jump, 1.0, 0.0)
	for sfx_player_id in range(4):
		if sfx_player_id > 4:
			break
		
		if sfx_player_id == 0:
			var sfx_player = $sfx
			
			if not sfx.playing:
				sfx_player.stream = file
				sfx_player.volume_linear = volume
				sfx_player.pitch_scale = pitch
				sfx_player.play()
			
		else:
			var sfx_player = get_node("sfx" + str(sfx_player_id))
			
			if not sfx_player.playing:
				sfx_player.stream = file
				sfx_player.volume_linear = volume
				sfx_player.pitch_scale = pitch
				sfx_player.play()

# Combined sound effects.
func sfx_combined_play():
	pass

func sfx_combined_fade(delta):
	pass
