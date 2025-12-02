extends CharacterBody2D

var circle_filepath = "res://Meme Mode/pictures/secondary/c1.png"
var arrow_filepath = "res://Meme Mode/pictures/secondary/a1.png"

var is_arrow = false #By default it's a circle.

var frozen = false

var scale_up_forever = false
var rotates = false

var anim_scale_loop = false
var anim_rotate = false
var anim_opacity_loop = true

var scale_x = 1
var scale_y = 1

var rotated_deg = 0

var rotate_speed = 1
var rotate_left = false

var rotate_direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_arrow:
		$arrow.visible = true
		
		var x = randi_range(0, 3)
		if x != 3 : $image.visible = false
		
		rotated_deg = randi_range(0, 360)
		
		$AnimationPlayer2.speed_scale = randf_range(0.5, 2)
		
		var rolled_arrow_anim = randi_range(0, 4)
		if rolled_arrow_anim == 0:
			$AnimationPlayer2.play("rotate_around")
		elif rolled_arrow_anim == 1:
			$AnimationPlayer2.play("rotate_around_2")
		elif rolled_arrow_anim == 2:
			$AnimationPlayer2.play("rotate_around_loopBack")
		elif rolled_arrow_anim == 3:
			$AnimationPlayer2.play("rotate_around_2_loopBack")
		elif rolled_arrow_anim == 4:
			pass
	else:
		$arrow.visible = false
	
	var rolled_frozen = randi_range(0, 3)
	if is_arrow:
		if rolled_frozen == 3:
			frozen = true
		else:
			frozen = false
	else:
		if rolled_frozen != 3:
			frozen = true
		else:
			frozen = false
	
	scale = Vector2(scale_x, scale_y)
	
	if anim_scale_loop:
		$AnimationPlayer.speed_scale = randf_range(0.4, 1.2)
		$AnimationPlayer.play("scaleLoop")
		scale = Vector2(randf_range(0.8, 3), randf_range(0.4, 2))
	
	if anim_opacity_loop:
		$AnimationPlayer.speed_scale = randf_range(0.3, 3)
		$AnimationPlayer.play("opacityLoop")
	
	if rotate_left:
		rotate_direction = -1
	else:
		rotate_direction = 1
	
	
	var rolled_is_alt_circle = randi_range(0, 1)
	if rolled_is_alt_circle:
		
		#randomize circle graphic
		var circle_total = 6
		var rolled_circle = randi_range(1, circle_total)
		while circle_total > 0:
			if rolled_circle == circle_total:
				var file_path = "res://Meme Mode/pictures/secondary/c" + str(circle_total)
				var file_type : String
				if ResourceLoader.exists(file_path + ".png"):
					file_type = ".png"
				elif ResourceLoader.exists(file_path + ".jpg"):
					file_type = ".jpg"
				elif ResourceLoader.exists(file_path + ".jpeg"):
					file_type = ".jpeg"
				
				print("loading file: " + file_path + file_type)
				circle_filepath = file_path + file_type
			
			circle_total -= 1
	
	$image.texture = load(circle_filepath)
	
	var rolled_is_alt_arrow = randi_range(0, 1)
	if rolled_is_alt_arrow:
		
		#randomize arrow graphic
		var arrow_total = 10
		var rolled_arrow = randi_range(1, arrow_total)
		while arrow_total > 0:
			if rolled_arrow == arrow_total:
				var file_path = "res://Meme Mode/pictures/secondary/a" + str(arrow_total)
				var file_type : String
				if ResourceLoader.exists(file_path + ".png"):
					file_type = ".png"
				elif ResourceLoader.exists(file_path + ".jpg"):
					file_type = ".jpg"
				elif ResourceLoader.exists(file_path + ".jpeg"):
					file_type = ".jpeg"
				
				print("loading file: " + file_path + file_type)
				arrow_filepath = file_path + file_type
			
			arrow_total -= 1
	
	$arrow.texture = load(arrow_filepath)
	
	
	await get_tree().create_timer(randf_range(0.5, 4), false).timeout
	$AnimationPlayer.speed_scale = randf_range(0.25, 12)
	$AnimationPlayer2.speed_scale = randf_range(0.25, 4)
	
	await get_tree().create_timer(randf_range(0.5, 8), false).timeout
	queue_free()


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if frozen:
		return
	
	if rotates:
		rotation_degrees = move_toward(rotation_degrees, randf_range(-1, 5) * 1000 * rotate_direction, delta * 10 * rotate_speed)
	
	if scale_up_forever:
		scale = scale.move_toward(Vector2(50, 50), delta / 3)
