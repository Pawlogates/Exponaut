extends Node2D

var meme_scene = preload("res://Meme Mode/memeMode_image.tscn")

var randomize_all = false

var image_filepath = preload("res://Meme Mode/pictures/5.jpg")
var sound_filepath = preload("res://Meme Mode/audio/1.mp3")
var music_filepath = preload("res://Meme Mode/audio/music/1.mp3")

var opacity_fade_out = true
var scale_down = false
var rotates = false

var scale_x = 1
var scale_y = 1

var vel_x = 0
var vel_y = 0

var fall_down = true

var rotate_speed = 1
var rotate_left = false

var mode_scaleLoop = false

var is_video = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if randomize_all:
		var rolled_video = randi_range(0, 3)
		if rolled_video == 3:
			is_video = true
		else:
			is_video = false
		
		var rolled_mode_scaleLoop = randi_range(0, 2)
		if rolled_mode_scaleLoop == 2:
			mode_scaleLoop = true
		else:
			mode_scaleLoop = false
		
		
		$Timer2.wait_time = randi_range(4, 16)
		$Timer2.start()
		$Timer3.wait_time = randf_range(0.1, 0.3)
		$Timer3.start()
		
		var rolled_img = randi_range(1, 18)
		if rolled_img == 1:
			image_filepath = preload("res://Meme Mode/pictures/1.png")
		elif rolled_img == 2:
			image_filepath = preload("res://Meme Mode/pictures/2.jpg")
		elif rolled_img == 3:
			image_filepath = preload("res://Meme Mode/pictures/3.jpg")
		elif rolled_img == 4:
			image_filepath = preload("res://Meme Mode/pictures/4.png")
		elif rolled_img == 5:
			image_filepath = preload("res://Meme Mode/pictures/5.jpg")
		elif rolled_img == 6:
			image_filepath = preload("res://Meme Mode/pictures/6.jpg")
		elif rolled_img == 7:
			image_filepath = preload("res://Meme Mode/pictures/7.png")
		elif rolled_img == 8:
			image_filepath = preload("res://Meme Mode/pictures/8.jpg")
		elif rolled_img == 9:
			image_filepath = preload("res://Meme Mode/pictures/9.png")
		elif rolled_img == 10:
			image_filepath = preload("res://Meme Mode/pictures/10.jpeg")
		elif rolled_img == 11:
			image_filepath = preload("res://Meme Mode/pictures/11.jpg")
		elif rolled_img == 12:
			image_filepath = preload("res://Meme Mode/pictures/12.jpg")
		elif rolled_img == 13:
			image_filepath = preload("res://Meme Mode/pictures/13.jpg")
		elif rolled_img == 14:
			image_filepath = preload("res://Meme Mode/pictures/14.jpg")
		elif rolled_img == 15:
			image_filepath = preload("res://Meme Mode/pictures/15.png")
		elif rolled_img == 16:
			image_filepath = preload("res://Meme Mode/pictures/16.png")
		elif rolled_img == 17:
			image_filepath = preload("res://Meme Mode/pictures/17.png")
		elif rolled_img == 18:
			image_filepath = preload("res://Meme Mode/pictures/18.jpg")
			
		var rolled_sfx = randi_range(1, 10)
		if rolled_sfx == 1:
			sound_filepath = preload("res://Meme Mode/audio/1.mp3")
		elif rolled_sfx == 2:
			sound_filepath = preload("res://Meme Mode/audio/2.mp3")
		elif rolled_sfx == 3:
			sound_filepath = preload("res://Meme Mode/audio/3.mp3")
		elif rolled_sfx == 4:
			sound_filepath = preload("res://Meme Mode/audio/4.wav")
		elif rolled_sfx == 5:
			sound_filepath = preload("res://Meme Mode/audio/5.wav")
		elif rolled_sfx == 6:
			sound_filepath = preload("res://Meme Mode/audio/6.wav")
		elif rolled_sfx == 7:
			sound_filepath = preload("res://Meme Mode/audio/7.mp3")
		elif rolled_sfx == 8:
			sound_filepath = preload("res://Meme Mode/audio/8.mp3")
		elif rolled_sfx == 9:
			sound_filepath = preload("res://Meme Mode/audio/9.mp3")
		elif rolled_sfx == 10:
			sound_filepath = preload("res://Meme Mode/audio/10.mp3")
		
		var rolled_music = randi_range(1, 5)
		if rolled_music == 1:
			music_filepath = preload("res://Meme Mode/audio/music/1.mp3")
		elif rolled_sfx == 2:
			music_filepath = preload("res://Meme Mode/audio/music/2.mp3")
		elif rolled_sfx == 3:
			music_filepath = preload("res://Meme Mode/audio/music/3.mp3")
		elif rolled_sfx == 4:
			music_filepath = preload("res://Meme Mode/audio/music/4.mp3")
		elif rolled_sfx == 5:
			music_filepath = preload("res://Meme Mode/audio/music/5.mp3")
		
		$AudioStreamPlayer2D.stream = music_filepath
		$AudioStreamPlayer2D.pitch_scale = randf_range(0.9, 1.1)
		$AudioStreamPlayer2D.volume_db = randf_range(0, 20)
		$AudioStreamPlayer2D.play()
		
		var rolled_opacity = randi_range(0, 1)
		if rolled_opacity:
			opacity_fade_out = true
		else:
			opacity_fade_out = false
		
		var rolled_scale = randi_range(0, 1)
		if rolled_scale:
			scale_down = true
		else:
			scale_down = false
		
		var rolled_rotates = randi_range(0, 3)
		if rolled_rotates == 3:
			rotates = true
		else:
			rotates = false
		
		var rolled_fall = randi_range(0, 2)
		if rolled_fall == 1 or rolled_fall == 2:
			fall_down = true
		else:
			fall_down = false
		
		vel_x = randi_range(-800, 800)
		vel_y = randi_range(-1000, 250)
		
		scale_x = randf_range(0.25, 1.25)
		scale_y = randf_range(0.25, 0.75)
		
		rotate_speed = randi_range(1, 15)
		
		var rolled_rotate_left = randi_range(0, 1)
		if rolled_rotate_left:
			rotate_left = true
		else:
			rotate_left = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	var image = meme_scene.instantiate()
	image.image_filepath = image_filepath
	image.opacity_fade_out = opacity_fade_out
	image.scale_down = scale_down
	if scale_down:
		image.position = position + Vector2(randi_range(-200, 200), randi_range(-200, 200))
	else:
		image.position = position
	image.rotates = rotates
	image.scale_x = scale_x
	image.scale_y = scale_y
	image.vel_x = vel_x
	image.vel_y = vel_y
	image.fall_down = fall_down
	image.rotate_speed = rotate_speed
	image.rotate_left = rotate_left
	image.mode_scaleLoop = mode_scaleLoop
	image.is_video = is_video
	
	$/root/World.add_child(image)
	
	if mode_scaleLoop or is_video:
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
