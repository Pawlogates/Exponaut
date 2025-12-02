extends Node2D

var main_rate : float = 1
var secondary_rate : float = 1
var major_greenscreen_rate : float = 1

var total_pictures = 20
var total_common = 10
var total_audio = 20
var total_music = 10
var total_common_music = 5
var total_videos = 10
var total_gifs = 10
var total_common_gifs = 5
var total_greenscreens = 10
var total_major = 10
var total_background_videos = 10


@onready var label = $Label
@onready var label2 = $Label2
@onready var label3 = $Label3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("decrease"):
		if Input.is_action_pressed("spawn1"):
			main_rate *= 1.05
		elif Input.is_action_pressed("spawn2"):
			secondary_rate *= 1.05
		elif Input.is_action_pressed("spawn3"):
			major_greenscreen_rate *= 1.05
		else:
			main_rate *= 1.05
			secondary_rate *= 1.05
			major_greenscreen_rate *= 1.05
		
		main_rate = clamp(main_rate, 0.05, 10)
		secondary_rate = clamp(secondary_rate, 0.05, 10)
		major_greenscreen_rate = clamp(major_greenscreen_rate, 0.05, 10)
		
		label.text = "Main spawn delay: " + str(main_rate)
		label2.text = "Secondary spawn delay: " + str(secondary_rate)
		label3.text = "Greenscreen spawn delay: " + str(major_greenscreen_rate)
	
		$AnimationPlayer.stop()
		$AnimationPlayer.play("fade_out")
	
	elif Input.is_action_pressed("increase"):
		if Input.is_action_pressed("spawn1"):
			main_rate *= 0.95
		elif Input.is_action_pressed("spawn2"):
			secondary_rate *= 0.95
		elif Input.is_action_pressed("spawn3"):
			major_greenscreen_rate *= 0.95
		else:
			main_rate *= 0.95
			secondary_rate *= 0.95
			major_greenscreen_rate *= 0.95
		
		main_rate = clamp(main_rate, 0.05, 10)
		secondary_rate = clamp(secondary_rate, 0.05, 10)
		major_greenscreen_rate = clamp(major_greenscreen_rate, 0.05, 10)
	
		label.text = "Main spawn delay: " + str(main_rate)
		label2.text = "Secondary spawn delay: " + str(secondary_rate)
		label3.text = "Greenscreen spawn delay: " + str(major_greenscreen_rate)
	
		$AnimationPlayer.stop()
		$AnimationPlayer.play("fade_out")


func randomize_rates():
	main_rate = randf_range(0.25, 4)
	secondary_rate = randf_range(0.25, 4)
	major_greenscreen_rate = randf_range(0.25, 4)
	
	#$AnimationPlayer.play("fade_out")
	#label.text = "Main spawn delay: " + str(main_rate)
	#label2.text = "Secondary spawn delay: " + str(secondary_rate)
	#label3.text = "Greenscreen spawn delay: " + str(major_greenscreen_rate)
