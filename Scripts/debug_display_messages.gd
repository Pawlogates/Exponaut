extends CanvasLayer

@onready var text_container: Control = $text_container
@onready var bg: ColorRect = $bg

var queued_messages : Array
var active_messages = 0

var bg_highest_x = 0
var bg_highest_y = 0


func _ready():
	insert_queued_messages()
	Globals.refresh_info.connect(insert_queued_messages)

func _physics_process(delta: float) -> void:
	pass


func insert_queued_messages():
	queued_messages.append_array(Globals.display_messages_debug_queued)
	Globals.display_messages_debug_queued.clear()
	
	var bg_size = Vector2(0, 0)
	
	if queued_messages:
		for message in queued_messages:
			print("Adding console message: " + str(message))
			active_messages += 1
			
			var label = Globals.scene_debug_message.instantiate()
			
			label.text = (str(message))
			label.id = active_messages
			
			var position_valid = false
			while not position_valid:
				position_valid = true
				for label_old in text_container.get_children():
					if label.id == label_old.id:
						label.id -= 1
						position_valid = false
			
			label.position.y = 24 * label.id
			label.position.x = 0
			
			text_container.add_child(label)
			update_bg(message)
	
	queued_messages.clear()


func _on_close_pressed() -> void:
	queue_free()


func update_bg(message):
	var new_size_x = len(message) * 8
	var new_size_y = (active_messages + 1) * 24
	
	if bg.size.x < new_size_x:
		bg.size.x = new_size_x
	
	if bg.size.y < new_size_y:
		bg.size.y = new_size_y
	
	if active_messages <= 0:
		bg.size.x = new_size_x
		bg.size.y = new_size_y
		new_size_x = 0
		new_size_y = 0
