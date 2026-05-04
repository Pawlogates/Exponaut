extends Button

@onready var leaderboard : Node = get_tree().get_first_node_in_group("leaderboard_level")

@export var source_name : String = "none"


func _on_pressed() -> void:
	leaderboard.source = source_name
	leaderboard.refresh_entries(leaderboard.level_id)
	
	if source_name == "online":
		Globals.server_to_dirpath(Globals.d_recordings_online)
