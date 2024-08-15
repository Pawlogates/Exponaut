extends CharacterBody2D

var image_filepath = CompressedTexture2D

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

var rotate_direction = 1

var mode_scaleLoop = false

var is_video = false
var video_filepath = preload("res://Meme Mode/videos/1.ogv")
var video_randomize = true
var video_scene = preload("res://Meme Mode/memeMode_video.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if mode_scaleLoop:
		$AnimationPlayer.speed_scale = randf_range(0.5, 1.5)
		$AnimationPlayer.play("scaleLoop")
	if not mode_scaleLoop and not is_video:
		if not scale_down:
			scale = Vector2(0.01, 0.01)
	
	if rotate_left:
		rotate_direction = -1
	else:
		rotate_direction = 1
	
	$image.texture = image_filepath
	velocity = Vector2(randi_range(-500, 250), randi_range(-500, 250))
	scale.x = scale_x
	scale.y = scale_y
	
	if is_video:
		if video_randomize:
			var rolled_video = randi_range(1, 5)
			if rolled_video == 1:
				video_filepath = preload("res://Meme Mode/videos/1.ogv")
			elif rolled_video == 2:
				video_filepath = preload("res://Meme Mode/videos/2.ogv")
			elif rolled_video == 3:
				video_filepath = preload("res://Meme Mode/videos/3.ogv")
			elif rolled_video == 4:
				video_filepath = preload("res://Meme Mode/videos/4.ogv")
			elif rolled_video == 5:
				video_filepath = preload("res://Meme Mode/videos/5.ogv")
			elif rolled_video == 6:
				video_filepath = preload("res://Meme Mode/videos/6.ogv")
			elif rolled_video == 7:
				video_filepath = preload("res://Meme Mode/videos/7.ogv")
		
		var video = video_scene.instantiate()
		video.position += Vector2(-300, -150)
		video.scale = Vector2(randf_range(0.8, 3), randf_range(0.8, 3))
		video.stream = video_filepath
		$image.add_child(video)
		$image.self_modulate.a = 0
	
	await get_tree().create_timer(randi_range(5, 30), false).timeout
	queue_free()


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mode_scaleLoop or is_video:
		return
		
	if fall_down:
		velocity.y += gravity / 2 * delta
	
	if scale_down:
		scale = scale.move_toward(Vector2(0, 0), delta / 2)
	else:
		scale = scale.move_toward(Vector2(1, 1), delta * 5)
	
	if opacity_fade_out:
		modulate.a = move_toward(modulate.a, 0, delta / 5)
	if rotates:
		rotation_degrees = move_toward(rotation_degrees, 1000 * rotate_direction, delta * 10 * rotate_speed)
	
	move_and_slide()
