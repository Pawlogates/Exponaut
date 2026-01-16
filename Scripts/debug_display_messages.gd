extends CanvasLayer

@onready var message_container: Control = $message_container
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
	Globals.messages_refresh.connect(insert_queued_messages)
	Globals.messages_debug_added.connect(insert_queued_messages)
	Globals.messages_debug_removed.connect(correct_message_positions)
	animation_ui.play("show")

func _physics_process(delta: float) -> void:
	pass


func insert_queued_messages():
	queued_messages.append_array(Globals.display_messages_debug_queued)
	Globals.display_messages_debug_queued.clear()
	
	var bg_size = Vector2(0, 0)
	
	if queued_messages:
		for message in queued_messages:
			
			var is_repeat = false
			
			# If the same message is currently displayed, make this one a "repeat" (adds a repeat count to the original message).
			for label_old in message_container.get_children():
				if message == label_old.message:
					label_old.repeats += 1
					label_old.handle_repeats()
					label_old.c_remove.start()
					label_old.fade_out_active = false
					label_old.modulate.a = 1.0
					
					is_repeat = true
			
			if is_repeat : continue
			
			print("Adding debug display message: " + str(message))
			
			var label = Globals.scene_debug_message.instantiate()
			
			label.message = (str(message))
			label.id = 0
			
			var position_valid = false
			while not position_valid:
				position_valid = true
				for label_old in message_container.get_children():
					if label.id == label_old.id:
						label.id += 1
						position_valid = false
			
			label.position.y = letter_y * label.id
			label.position.x = 0
			
			update_bg(message, label.id)
			
			message_container.add_child(label)
			active_messages += 1 # It's crucial that this property increases BEFORE the background update.
	
	queued_messages.clear()
	correct_message_positions() # This function also resets the scale for all message labels but the last one, which becomes bigger instead.


func _on_close_pressed() -> void:
	animation_ui.play("hide")


func update_bg(message, message_id):
	print(active_messages)
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
	
	elif active_messages < 4 and active_messages > 0:
		if btn_close.position.x < clamp(new_size_x * 2, 0, 1894):
			btn_close.position.x = clamp(new_size_x * 2, 0, 1894)

func _on_animation_ui_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		queue_free()

func correct_message_positions():
	await get_tree().create_timer(0.05, true).timeout
	update_bg("", 0)
	
	var highest_message_id = 0
	var list_messages = message_container.get_children()
	
	for label in list_messages:
		
		label.position.y = letter_y * highest_message_id
		
		label.scale = Vector2(1, 1)
		
		if highest_message_id >= len(list_messages) -3: # Last three messages will be enlarged.
			label.scale = Vector2(2, 2)
			
			if active_messages > 1:
				label.position.y += letter_y * (highest_message_id - active_messages + 3)
		
		if highest_message_id == 0:
			update_bg(label.text, 0)
		
		highest_message_id += 1
