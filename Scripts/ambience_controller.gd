extends Node2D

@onready var layer_1 = %ambience_layer1
@onready var layer_2 = %ambience_layer2
@onready var layer_3 = %ambience_layer3
@onready var layer_4 = %ambience_layer4

@export var ambience_layer1_baseDelay = 90
@export var ambience_layer2_baseDelay = 90
@export var ambience_layer3_baseDelay = 90
@export var ambience_layer4_baseDelay = 90

@export var ambience_layer1_delayRange = 60
@export var ambience_layer2_delayRange = 60
@export var ambience_layer3_delayRange = 60
@export var ambience_layer4_delayRange = 60

@export var ambience_layer1_basePitch = 1
@export var ambience_layer2_basePitch = 1
@export var ambience_layer3_basePitch = 1
@export var ambience_layer4_basePitch = 1

@export var ambience_layer1_pitchRange = 0.2
@export var ambience_layer2_pitchRange = 0.2
@export var ambience_layer3_pitchRange = 0.2
@export var ambience_layer4_pitchRange = 0.2

@export var ambience_layer1_baseVolume = 1
@export var ambience_layer2_baseVolume = 1
@export var ambience_layer3_baseVolume = 1
@export var ambience_layer4_baseVolume = 1

@export var ambience_layer1_volumeRange = 0.6
@export var ambience_layer2_volumeRange = 0.6
@export var ambience_layer3_volumeRange = 0.6
@export var ambience_layer4_volumeRange = 0.6

var disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ambience_layer_randomize_delay()
	ambience_layer_randomize_pitch()
	ambience_layer_randomize_volume()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if disabled:
		return
	
	pass


#randomize all
func ambience_layer_randomize_delay():
	var x = 1
	while x <= 4: #4 loops
		var ambience_layer_baseDelay = get("ambience_layer" + str(x) + "_baseDelay")
		var ambience_layer_delayRange = get("ambience_layer" + str(x) + "_delayRange")
		var ambience_layer_delay = ambience_layer_baseDelay + randf_range(-ambience_layer_delayRange, ambience_layer_delayRange)
		ambience_layer_delay = abs(ambience_layer_delay)
		
		var timer = get_node("ambience_layer" + str(x) + "/" + "ambience" + str(x) + "_delay")
		timer.wait_time = ambience_layer_delay
		timer.start()
		
		x += 1

func ambience_layer_randomize_pitch():
	var x = 1
	while x <= 4: #4 loops
		var ambience_layer_basePitch = get("ambience_layer" + str(x) + "_basePitch")
		var ambience_layer_pitchRange = get("ambience_layer" + str(x) + "_delayRange")
		var ambience_layer_pitch = ambience_layer_basePitch + randf_range(-ambience_layer_pitchRange, ambience_layer_pitchRange)
		ambience_layer_pitch = abs(ambience_layer_pitch)
		
		var audioStreamPlayer = get_node("%ambience_layer" + str(x))
		audioStreamPlayer.pitch_scale = ambience_layer_pitch
		
		x += 1

func ambience_layer_randomize_volume():
	var x = 1
	while x <= 4: #4 loops
		var ambience_layer_baseVolume = get("ambience_layer" + str(x) + "_baseVolume")
		var ambience_layer_volumeRange = get("ambience_layer" + str(x) + "_volumeRange")
		var ambience_layer_volume = ambience_layer_baseVolume + randf_range(-ambience_layer_volumeRange, ambience_layer_volumeRange)
		ambience_layer_volume = abs(ambience_layer_volume)
		
		var audioStreamPlayer = get_node("%ambience_layer" + str(x))
		audioStreamPlayer.volume_db = ambience_layer_volume
		
		x += 1



#randomize single
func single_ambience_layer_randomize_delay(x):
	var ambience_layer_baseDelay = get("ambience_layer" + str(x) + "_baseDelay")
	var ambience_layer_delayRange = get("ambience_layer" + str(x) + "_delayRange")
	var ambience_layer_delay = ambience_layer_baseDelay + randf_range(-ambience_layer_delayRange, ambience_layer_delayRange)
	ambience_layer_delay = abs(ambience_layer_delay)
	
	var timer = get_node("%ambience" + str(x) + "_delay")
	timer.wait_time = ambience_layer_delay
	
	print(str(ambience_layer_delay) + " is the rolled ambience delay.")
	
	return ambience_layer_delay

func single_ambience_layer_randomize_pitch(x):
	var ambience_layer_basePitch = get("ambience_layer" + str(x) + "_basePitch")
	var ambience_layer_pitchRange = get("ambience_layer" + str(x) + "_pitchRange")
	var ambience_layer_pitch = ambience_layer_basePitch + randf_range(-ambience_layer_pitchRange, ambience_layer_pitchRange)
	ambience_layer_pitch = abs(ambience_layer_pitch)
	
	var audioStreamPlayer = get_node("%ambience_layer" + str(x))
	audioStreamPlayer.pitch_scale = ambience_layer_pitch
	
	print(str(ambience_layer_pitch) + " is the rolled ambience pitch.")
	
	return ambience_layer_pitch

func single_ambience_layer_randomize_volume(x):
	var ambience_layer_baseVolume = get("ambience_layer" + str(x) + "_baseVolume")
	var ambience_layer_volumeRange = get("ambience_layer" + str(x) + "_volumeRange")
	var ambience_layer_volume = ambience_layer_baseVolume + randf_range(-ambience_layer_volumeRange, ambience_layer_volumeRange)
	ambience_layer_volume = abs(ambience_layer_volume)
	
	var audioStreamPlayer = get_node("%ambience_layer" + str(x))
	audioStreamPlayer.volume_db = ambience_layer_volume
	
	print(str(ambience_layer_volume) + " is the rolled ambience volume.")
	
	return ambience_layer_volume

#delay timers
func _on_ambience_1_delay_timeout():
	if disabled:
		return
	
	single_ambience_layer_randomize_delay(1)
	single_ambience_layer_randomize_pitch(1)
	single_ambience_layer_randomize_volume(1)
	
	var timer = $ambience_layer1/ambience1_delay
	timer.start()
	%ambience_layer1.play()


func _on_ambience_2_delay_timeout():
	if disabled:
		return
	
	single_ambience_layer_randomize_delay(2)
	single_ambience_layer_randomize_pitch(2)
	single_ambience_layer_randomize_volume(2)
	
	var timer = $ambience_layer2/ambience2_delay
	timer.start()
	%ambience_layer2.play()


func _on_ambience_3_delay_timeout():
	if disabled:
		return
	
	single_ambience_layer_randomize_delay(3)
	single_ambience_layer_randomize_pitch(3)
	single_ambience_layer_randomize_volume(3)
	
	var timer = $ambience_layer3/ambience3_delay
	timer.start()
	%ambience_layer3.play()


func _on_ambience_4_delay_timeout():
	if disabled:
		return
	
	single_ambience_layer_randomize_delay(4)
	single_ambience_layer_randomize_pitch(4)
	single_ambience_layer_randomize_volume(4)
	
	var timer = $ambience_layer4/ambience4_delay
	timer.start()
	%ambience_layer4.play()
