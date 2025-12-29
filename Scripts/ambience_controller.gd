extends Node2D

@onready var layer1 = %layer1
@onready var layer2 = %layer2
@onready var layer3 = %layer3
@onready var layer4 = %layer4

@export var layer1_delay_base = 90
@export var layer2_delay_base = 90
@export var layer3_delay_base = 90
@export var layer4_delay_base = 90

@export var layer1_delay_range = 60
@export var layer2_delay_range = 60
@export var layer3_delay_range = 60
@export var layer4_delay_range = 60

@export var layer1_pitch_base = 1
@export var layer2_pitch_base = 1
@export var layer3_pitch_base = 1
@export var layer4_pitch_base = 1

@export var layer1_pitchRange = 0.2
@export var layer2_pitchRange = 0.2
@export var layer3_pitchRange = 0.2
@export var layer4_pitchRange = 0.2

@export var layer1_volume_base = 1
@export var layer2_volume_base = 1
@export var layer3_volume_base = 1
@export var layer4_volume_base = 1

@export var layer1_volume_range = 0.6
@export var layer2_volume_range = 0.6
@export var layer3_volume_range = 0.6
@export var layer4_volume_range = 0.6

var enabled = false
var active = false # Equal to "true" while any sound is being played currently.

# Called when the node enters the scene tree for the first time.
func _ready():
	layer_randomize_delay()
	layer_randomize_pitch()
	layer_randomize_volume()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not enabled:
		return
	
	pass


#randomize all
func layer_randomize_delay():
	var x = 1
	while x <= 4: #4 loops
		var layer_delay_base = get("layer" + str(x) + "_delay_base")
		var layer_delay_range = get("layer" + str(x) + "_delay_range")
		var layer_delay = layer_delay_base + randf_range(-layer_delay_range, layer_delay_range)
		layer_delay = abs(layer_delay)
		
		var timer = get_node("layer" + str(x) + "/" + "cooldown")
		timer.wait_time = layer_delay
		timer.start()
		
		x += 1

func layer_randomize_pitch():
	var x = 1
	while x <= 4: #4 loops
		var layer_pitch_base = get("layer" + str(x) + "_pitch_base")
		var layer_pitchRange = get("layer" + str(x) + "_delay_range")
		var layer_pitch = layer_pitch_base + randf_range(-layer_pitchRange, layer_pitchRange)
		layer_pitch = abs(layer_pitch)
		
		var audioStreamPlayer = get_node("%layer" + str(x))
		audioStreamPlayer.pitch_scale = layer_pitch
		
		x += 1

func layer_randomize_volume():
	var x = 1
	while x <= 4: #4 loops
		var layer_volume_base = get("layer" + str(x) + "_volume_base")
		var layer_volume_range = get("layer" + str(x) + "_volume_range")
		var layer_volume = layer_volume_base + randf_range(-layer_volume_range, layer_volume_range)
		layer_volume = abs(layer_volume)
		
		var audioStreamPlayer = get_node("%layer" + str(x))
		audioStreamPlayer.volume_db = layer_volume
		
		x += 1


#randomize single
func single_layer_randomize_delay(x):
	var layer_delay_base = get("layer" + str(x) + "_delay_base")
	var layer_delay_range = get("layer" + str(x) + "_delay_range")
	var layer_delay = layer_delay_base + randf_range(-layer_delay_range, layer_delay_range)
	layer_delay = abs(layer_delay)
	
	var timer = get_node("layer" + str(x) + "/" + "cooldown")
	timer.wait_time = layer_delay
	
	print(str(layer_delay) + " is the rolled ambience delay.")
	
	return layer_delay


func single_layer_randomize_pitch(x):
	var layer_pitch_base = get("layer" + str(x) + "_pitch_base")
	var layer_pitchRange = get("layer" + str(x) + "_pitchRange")
	var layer_pitch = layer_pitch_base + randf_range(-layer_pitchRange, layer_pitchRange)
	layer_pitch = abs(layer_pitch)
	
	var audioStreamPlayer = get_node("%layer" + str(x))
	audioStreamPlayer.pitch_scale = layer_pitch
	
	print(str(layer_pitch) + " is the rolled ambience pitch.")
	
	return layer_pitch


func single_layer_randomize_volume(x):
	var layer_volume_base = get("layer" + str(x) + "_volume_base")
	var layer_volume_range = get("layer" + str(x) + "_volume_range")
	var layer_volume = layer_volume_base + randf_range(-layer_volume_range, layer_volume_range)
	layer_volume = abs(layer_volume)
	
	var audioStreamPlayer = get_node("%layer" + str(x))
	audioStreamPlayer.volume_db = layer_volume
	
	print(str(layer_volume) + " is the rolled ambience volume.")
	
	return layer_volume


func _on_cooldown1_timeout() -> void:
	layer_play(1)


func _on_cooldown2_timeout() -> void:
	layer_play(2)


func _on_cooldown3_timeout() -> void:
	layer_play(3)


func _on_cooldown4_timeout() -> void:
	layer_play(4)


func layer_play(id : int):
	if not enabled:
		return
	
	single_layer_randomize_delay(id)
	single_layer_randomize_pitch(id)
	single_layer_randomize_volume(id)
	
	var timer = $layer2/ambience2_delay
	timer.start()
	var target_node = str("%layer", str(id))
	get_node(target_node).play()
