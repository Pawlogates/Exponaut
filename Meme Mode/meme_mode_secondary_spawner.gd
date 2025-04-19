extends Node2D

@onready var settings = $/root/World/meme_mode_controller/Settings

var color_rect_visible = false #DEBUG

var meme_scene = preload("res://Meme Mode/memeMode_secondary.tscn")

var randomize_all = false

var is_arrow = false
var is_text = false

var only_one = true
var sfx_only_one = true

var sound_filepath = preload("res://Meme Mode/audio/1.mp3")
var music_filepath = preload("res://Meme Mode/audio/music/1.mp3")

var anim_scale_loop = false
var anim_opacity_loop = true

var scale_up_forever = false
var rotates = false

var rotated_deg = 0

var scale_x = 1
var scale_y = 1

var vel_x = 0
var vel_y = 0

var fall_down = true

var rotate_speed = 1
var rotate_left = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#DEBUG
	if color_rect_visible:
		$ColorRect.visible = true
	#DEBUG END
	
	if randomize_all:
		var rolled_only_one = randi_range(0, 1)
		if rolled_only_one != 1:
			only_one = true
		else:
			only_one = false
		
		var rolled_is_text = randi_range(0, 2)
		if rolled_is_text == 2:
			is_text = true
		else:
			is_text = false
		
		if is_text:
			handle_text()
			only_one = true
		
		var rolled_is_arrow = randi_range(0, 2)
		if rolled_is_arrow == 2:
			is_arrow = true
		else:
			is_arrow = false
		
		var rolled_anim_scale_loop = randi_range(0, 4)
		if rolled_anim_scale_loop == 4:
			anim_scale_loop = true
		else:
			anim_scale_loop = false
		
		var rolled_anim_opacity_loop = randi_range(0, 2)
		if rolled_anim_opacity_loop == 2:
			anim_opacity_loop = true
		else:
			anim_opacity_loop = false
		
		var rolled_sfx_only_one = randi_range(0, 3)
		if rolled_sfx_only_one != 3:
			sfx_only_one = true
		else:
			sfx_only_one = false
		
		
		$Timer.wait_time = randf_range(0.5, 3)
		$Timer.start()
		$Timer2.wait_time = randf_range(0.25, 6)
		$Timer2.start()
		$Timer3.wait_time = randf_range(0.5, 2)
		$Timer3.start()
		
		
		var sfx_total = settings.total_audio
		var rolled_sfx = randi_range(1, sfx_total)
		while sfx_total > 0:
			if rolled_sfx == sfx_total:
				var file_path = "res://Meme Mode/audio/" + str(sfx_total)
				var file_type : String
				if ResourceLoader.exists(file_path + ".mp3"):
					file_type = ".mp3"
				elif ResourceLoader.exists(file_path + ".wav"):
					file_type = ".wav"
				
				print("loading file: " + file_path + file_type)
				sound_filepath = load(file_path + file_type)
			
			sfx_total -= 1
		
		
		var music_total = settings.total_music
		var rolled_music = randi_range(1, music_total)
		while music_total > 0:
			if rolled_music == music_total:
				var file_path = "res://Meme Mode/audio/music/" + str(music_total)
				var file_type : String
				if ResourceLoader.exists(file_path + ".mp3"):
					file_type = ".mp3"
				elif ResourceLoader.exists(file_path + ".wav"):
					file_type = ".wav"
				
				print("loading file: " + file_path + file_type)
				music_filepath = load(file_path + file_type)
			
			music_total -= 1
		
		$AudioStreamPlayer2D.stream = music_filepath
		$AudioStreamPlayer2D.pitch_scale = randf_range(0.9, 1.1)
		$AudioStreamPlayer2D.volume_db = randf_range(0, 20)
		$AudioStreamPlayer2D.play()
		
		var rolled_opacity = randi_range(0, 1)
		if rolled_opacity:
			anim_opacity_loop = true
		else:
			anim_opacity_loop = false
		
		var rolled_scale = randi_range(0, 1)
		if rolled_scale:
			scale_up_forever = true
		else:
			scale_up_forever = false
		
		var rolled_rotates = randi_range(0, 3)
		if rolled_rotates == 3:
			rotates = true
		else:
			rotates = false
		
		var rolled_fall = randi_range(0, 2)
		if rolled_fall != 0:
			fall_down = true
		else:
			fall_down = false
		
		scale_x = randf_range(0.5, 2)
		scale_y = randf_range(0.5, 2)
		
		rotate_speed = randf_range(1, 15)
		
		var rolled_rotate_left = randi_range(0, 1)
		if rolled_rotate_left:
			rotate_left = true
		else:
			rotate_left = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func handle_text():
	print("spawning text")
	var text = preload("res://Meme Mode/meme_mode_text.tscn").instantiate()
	text.position = position
	get_parent().add_child(text)


func _on_timer_timeout():
	var image = meme_scene.instantiate()
	
	image.is_arrow = is_arrow
	image.position = position
	image.anim_opacity_loop = anim_opacity_loop
	image.scale_up_forever = scale_up_forever
	image.rotated_deg = rotated_deg
	image.scale_x = scale_x
	image.scale_y = scale_y
	image.rotate_speed = rotate_speed
	image.rotate_left = rotate_left
	image.anim_scale_loop = anim_scale_loop
	image.anim_opacity_loop = anim_opacity_loop
	
	get_parent().add_child(image)
	
	if only_one:
		queue_free()


func _on_timer_2_timeout():
	queue_free()


var sfx = preload("res://Meme Mode/memeMode_sfx.tscn")

func _on_timer_3_timeout():
	var x = randi_range(0, 6)
	if not x:
		return
	
	var sound_effect = sfx.instantiate()
	sound_effect.stream = sound_filepath
	sound_effect.pitch_scale = randf_range(0.8, 1.2)
	sound_effect.volume_db = randf_range(-10, 20)
	add_child(sound_effect)
	
	if sfx_only_one:
		$Timer3.queue_free()
