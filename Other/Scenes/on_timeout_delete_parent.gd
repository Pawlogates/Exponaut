extends Timer

func _ready() -> void:
	timeout.connect(delete_parent)

func delete_parent():
	get_parent().queue_free()
