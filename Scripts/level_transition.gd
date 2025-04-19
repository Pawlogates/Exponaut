extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var blackScreen = $ColorRect

@onready var info_text_display = $info_textDisplay_root


func fade_from_black():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished

func fade_from_black_slow():
	animation_player.play("fade_from_black_slow")
	await animation_player.animation_finished


func fade_to_black_verySlow():
	animation_player.play("fade_to_black_verySlow")
	await animation_player.animation_finished

func fade_to_black():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished

func fade_to_black_fast():
	animation_player.play("fade_to_black_fast")
	await animation_player.animation_finished

func fade_to_black_slow():
	animation_player.play("fade_to_black_slow")
	await animation_player.animation_finished


func _ready():
	blackScreen.color.a = 0.0


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
		elif get_tree().paused == true:
			get_tree().paused = false
	
	
	elif Input.is_action_just_pressed("debug_mode"):
		Globals.debug_mode = true
		
		if not get_node_or_null("/root/World"):
			return
		
		Globals.playerHP = 99999
		
		#if get_node_or_null("/root/World/HUD/Debug Screen"):
			#$/root/World/HUD/"Debug Screen"._on_toggle_ambience_pressed()
			#$/root/World/HUD/"Debug Screen"._on_toggle_music_pressed()
		
		Globals.infoSign_current_text = str("Debug mode has been activated!")
		Globals.infoSign_current_size = 0
		Globals.info_sign_touched.emit()
