extends VideoStreamPlayer

@onready var settings = $/root/World/meme_mode_controller/Settings

var major = false

func _ready() -> void:
	if major:
		var video_total = settings.total_major
		var rolled_video = randi_range(1, video_total)
		while video_total > 0:
			if rolled_video == video_total:
				var file_path = "res://Meme Mode/videos/greenscreens/major/" + str(video_total)
				var file_type : String
				if ResourceLoader.exists(file_path + ".ogv"):
					file_type = ".ogv"
				
				print("loading file: " + file_path + file_type)
				stream = load(file_path + file_type)
				play()
			
			video_total -= 1
		
		await get_tree().create_timer(randf_range(2, 16), false).timeout
		queue_free()


func _on_finished() -> void:
	if randi_range(0, 2) == 2:
		queue_free()
		print("major greenscreen deleted")
	else:
		play()
		print("major greenscreen restarted")
