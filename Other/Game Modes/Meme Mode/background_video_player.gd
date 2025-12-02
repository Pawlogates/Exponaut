extends VideoStreamPlayer

@onready var settings = $/root/World/meme_mode_controller/Settings

var video_filepath = "res://background videos/1.ogv"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_video()
	$Timer.wait_time = randf_range(4, 40)
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_finished() -> void:
	randomize_video()

func randomize_video():
	var video_total = settings.total_background_videos
	var rolled_video = randi_range(1, video_total)
	while video_total > 0:
		if rolled_video == video_total:
			var folder_path = "res://Meme Mode/videos/background videos/" + str(video_total)
			var file_type : String
			if ResourceLoader.exists(folder_path + ".ogv"):
				file_type = ".ogv"
			
			print("loading file: " + folder_path + file_type)
			video_filepath = folder_path + file_type
		
		video_total -= 1
	
	stream = load(video_filepath)
	volume_db = randi_range(0, 30)
	play()

func _on_timer_timeout() -> void:
	randomize_video()
	$Timer.wait_time = randf_range(4, 40)
	$Timer.start()
