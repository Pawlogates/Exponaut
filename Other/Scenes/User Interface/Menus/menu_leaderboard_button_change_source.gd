extends Button

@onready var leaderboard : Node = get_tree().get_first_node_in_group("leaderboard_level")

@export var source_name : String = "none"


func _on_pressed() -> void:
	leaderboard.source = source_name
	leaderboard.refresh_entries(leaderboard.level_id)
	if source_name == "online":
		Globals.dirpath_to_server(Globals.d_recordings_local_best, "leaderboard/upload")
		await get_tree().create_timer(4.0, true).timeout
		Globals.server_to_dirpath(Globals.d_recordings_online)
