extends Node3D

@onready var settings = $/root/World/meme_mode_controller/Settings

var image_filepath = "res://Meme Mode/pictures/5.jpg"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_image()
	
	get_parent().get_parent().position += Vector2(randi_range(-2000, 0), randi_range(-1000, 0))
	
	$Timer.wait_time = randf_range(0.5, 8)
	$Timer.start()
	
	$AnimationPlayer.speed_scale = randf_range(0.25, 2)
	
	get_parent().get_parent().visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func random_image():
	var img_total = settings.total_pictures
	var rolled_img = randi_range(1, img_total)
	while img_total > 0:
		if rolled_img == img_total:
			var file_path = "res://Meme Mode/pictures/" + str(img_total)
			var file_type : String
			if ResourceLoader.exists(file_path + ".png"):
				file_type = ".png"
			elif ResourceLoader.exists(file_path + ".jpg"):
				file_type = ".jpg"
			elif ResourceLoader.exists(file_path + ".jpeg"):
				file_type = ".jpeg"
			
			print("loading file: " + file_path + file_type)
			image_filepath = file_path + file_type
		
		img_total -= 1
	
	for image in $images.get_children():
		image.texture = load(image_filepath)

func _on_timer_timeout() -> void:
	queue_free()
