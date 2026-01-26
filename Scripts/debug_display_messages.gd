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
	Globals.messages_debug_removed.connect(correct_messages_order)
	animation_ui.play("show")

func _physics_process(delta: float) -> void:
	btn_close.position = btn_close.position.lerp(btn_close_target_pos, delta * 4)


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
			
			print("DEBUG MESSAGE: " + str(message))
			
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
			label.target_position = label.position
			label.target_scale = label.scale
			
			update_bg(message, label.id)
			
			message_container.add_child(label)
			active_messages += 1 # It's crucial that this property increases BEFORE the background update.
	
	queued_messages.clear()
	correct_messages_order() # This function also resets the scale for all message labels but the last 3, which become bigger instead.


func _on_close_pressed() -> void:
	animation_ui.play("hide")


var btn_close_target_pos : Vector2 = Vector2(0, 0)

func update_bg(message, message_id):
	var new_size_x = len(message) * letter_x + 4
	var new_size_y = (message_id + 1) * letter_y
	
	if bg.size.x < new_size_x:
		bg.size.x = new_size_x
		btn_close_target_pos.x = clamp(new_size_x, 0, 1894)
	
	if bg.size.y < new_size_y:
		bg.size.y = new_size_y
	
	if active_messages <= 0:
		new_size_x = 0
		new_size_y = 0
		bg.size.x = new_size_x
		bg.size.y = new_size_y
		btn_close_target_pos.x = 0
		
	
	elif active_messages < 4 and active_messages > 0:
		if btn_close_target_pos.x < clamp(new_size_x * 2, 0, 1894):
			btn_close_target_pos.x = clamp(new_size_x * 2, 0, 1894)
			bg.size.x = new_size_x * 2

func _on_animation_ui_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		queue_free()


var message_following_mouse_id : int = -1

func correct_messages_order():
	await get_tree().create_timer(0.05, true).timeout
	update_bg("", 0)
	
	var highest_message_id : int = 0
	var highest_message_height_multiplier : float = 0.0
	var list_messages = message_container.get_children()
	
	for label in list_messages:
		
		if message_following_mouse_id != -1 and message_following_mouse_id != label.following_mouse_id : label.mouse_filter = label.MOUSE_FILTER_IGNORE
		else : label.mouse_filter = label.MOUSE_FILTER_STOP
		
		label.id = highest_message_id
		if label.remove_multiplier == 0.1 : continue # Skip if debug message is currently following the mouse.
		
		if float(label.message_scale) == -1.0:
			label.position.y = letter_y * highest_message_id
			label.scale = Vector2(1, 1)
		else:
			label.position.y = letter_y * highest_message_height_multiplier
			label.scale = Vector2(float(label.message_scale), float(label.message_scale))
		
		if highest_message_id >= len(list_messages) -3: # Last three messages will be enlarged.
			if float(label.message_scale) == -1.0 : label.scale = Vector2(2, 2)
			else : label.scale = Vector2(float(label.message_scale), float(label.message_scale)) * 2
			
			if active_messages > 1:
				label.position.y += letter_y * (highest_message_id - active_messages + 3)
		
		if highest_message_id == 0:
			update_bg(label.text, 0)
		
		highest_message_id += 1
		highest_message_height_multiplier += 1.0 * label.scale.y
		
		label.target_position = label.position
		label.target_scale = label.scale
		label.z_index += int(scale.y * 1.5)


func refresh_messages():
	var list_messages = message_container.get_children()
	for label in list_messages:
		label.set_remove_cooldown()
	
	Globals.dm("Refreshed all debug display messages.", "GREEN", 2.0, 1.0)

func delete_messages(only_currently_focused : bool = false):
	var list_messages = message_container.get_children()
	for label in list_messages:
		
		if only_currently_focused:
			if label.currently_focused:
				label.queue_free()
				active_messages -= 1
				Globals.dm("Deleted the debug display message currently being under the mouse.", 99, 1.0)
		
		else:
			label.queue_free()
			active_messages -= 1
			Globals.dm("Deleted all display messages.", "PURPLE")
			reset_bg()

func message_start_following_mouse():
	var list_messages = message_container.get_children()
	for label in list_messages:
		if label.currently_focused:
			label.following_mouse_id = label.id
			label.display.message_following_mouse_id = label.following_mouse_id
			
			label.scale = label.target_scale + Vector2(0.5, 0.5)
			label.position += Vector2(0, -4)
			
			label.target_position_follow_mouse = Vector2(label.position.x, label.position.y + 8)
			
			label.animation_player.stop()
			label.animation_player.play("focus_entered")
			
			label.z_index = 50 * label.id
			label.remove_multiplier = 0.1
			
			label.fade_out_active = false
			label.c_remove.wait_time = 20
			label.c_remove.start()


func reset_bg():
	bg.size = Vector2(0, 0)
	btn_close_target_pos = Vector2(0, 0)
