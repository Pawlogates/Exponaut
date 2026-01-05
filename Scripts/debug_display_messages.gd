extends CanvasLayer

@onready var text_container: Control = $text_container
@onready var bg: ColorRect = $bg
@onready var animation_ui: AnimationPlayer = $animation_ui
@onready var btn_close: Button = $close

var queued_messages : Array # The most important property. It's values will be displayed on the display one after another.

var active_messages = 0

var bg_highest_x = 0
var bg_highest_y = 0

const letter_x = 6
const letter_y = 18


func _ready():
	insert_queued_messages()
	Globals.refresh_info.connect(insert_queued_messages)
	animation_ui.play("show")

func _physics_process(delta: float) -> void:
	pass


func insert_queued_messages():
	queued_messages.append_array(Globals.display_messages_debug_queued)
	Globals.display_messages_debug_queued.clear()
	
	var bg_size = Vector2(0, 0)
	
	if queued_messages:
		for message in queued_messages:
			print("Adding debug display message: " + str(message))
			
			var label = Globals.scene_debug_message.instantiate()
			
			label.text = (str(message))
			label.id = 0
			
			var position_valid = false
			while not position_valid:
				position_valid = true
				for label_old in text_container.get_children():
					print(len(text_container.get_children()))
					if label.id == label_old.id:
						label.id += 1
						position_valid = false
			
			label.position.y = letter_y * label.id
			label.position.x = 0
			
			text_container.add_child(label)
			active_messages += 1 # It's crucial that this property increases BEFORE the background update.
			update_bg(message, label.id)
	
	queued_messages.clear()


func _on_close_pressed() -> void:
	animation_ui.play("hide")


func update_bg(message, message_id):
	var new_size_x = len(message) * letter_x + 4
	var new_size_y = (message_id + 1) * letter_y
	
	if bg.size.x < new_size_x:
		bg.size.x = new_size_x
		btn_close.position.x = clamp(new_size_x, 0, 1894)
	
	if bg.size.y < new_size_y:
		bg.size.y = new_size_y
	
	if active_messages <= 0:
		bg.size.x = new_size_x
		bg.size.y = new_size_y
		new_size_x = 0
		new_size_y = 0
		btn_close.position.x = 0

func _on_animation_ui_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		queue_free()
