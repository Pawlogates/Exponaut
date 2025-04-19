extends Node2D

@onready var settings = $/root/World/meme_mode_controller/Settings

var image_filepath = "res://Meme Mode/pictures/5.jpg"

var start_position = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position + Vector2(randi_range(-500, 500), randi_range(-500, 500))
	position = target_position
	
	random_image()
	$image.texture = load(image_filepath)
	
	$Timer.wait_time = randf_range(0.5, 12)
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a = move_toward(modulate.a, 1, delta)

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

func _on_timer_timeout() -> void:
	queue_free()


var target_position = Vector2(0, 0)

func _on_timer_2_timeout() -> void:
	target_position = Vector2(start_position.x + randi_range(-150, 150), start_position.y + randi_range(-150, 150))
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, 1)
