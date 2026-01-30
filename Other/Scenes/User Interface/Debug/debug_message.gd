extends Label

var message = "none"
var repeats = 0

@onready var c_remove: Timer = $cooldown_remove
@onready var display = $/root/Overlay/debug_display_messages
@onready var message_container = $/root/Overlay/debug_display_messages/message_container
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var l_message_modification = ["i", "s", "t"]
var l_message_modification_value = []

var id : int = 0
var target_position : Vector2 = Vector2(0, 0)
var target_scale : Vector2 = Vector2(0, 0)

var following_mouse_id : int = -1
var target_position_follow_mouse : Vector2 = Vector2(0, 0)

var cooldown_remove = 4.0

var message_visible = ""

var message_importance = ""
var message_scale = ""
var message_time = ""

var remove_multiplier : float = 1.0


func _ready() -> void:
	var message_split = message.split("[/BREAK/]")
	
	message_visible = message_split[0]
	if message_visible == message : print(str("Something is wrong about this debug message: %s" % message))
	
	for part in message_split:
		if part == message_split[0] : continue
		
		if part.ends_with("i"):
			part = part.replace("i", "")
			
			if part.is_valid_float():
				message_importance = float(part)
				
				if message_importance == 99:
					material = Globals.material_rainbow
					
				else:
					modulate = Color.PURPLE / message_importance * 4
					modulate.a = 1.0
			
			else:
				message_importance = part
				if not message_importance == "none":
					modulate = Color(message_importance)
		
		elif part.ends_with("s"):
			part.replace("s", "")
			
			message_scale = part
			if float(message_scale) != -1.0 : scale += Vector2(float(message_scale), float(message_scale))
		
		elif part.ends_with("t"):
			part.replace("t", "")
			
			message_time = part
			if float(message_time) != -1.0 : cooldown_remove = float(message_time)
		
		else:
			print(str("Something is wrong about this debug message segment: %s" % part))
			print(str("The full message: %s" % message_split))
			for segment in message_split : print(segment)
	
	
	c_remove.wait_time = cooldown_remove
	c_remove.start()
	
	text = message_visible
	
	await get_tree().create_timer(0.1, true).timeout # The message positions also get corrected after a delay, so it looks best when a new message isn't visible immediately.
	
	visible = true

func _physics_process(delta: float) -> void:
	if fade_out_active : modulate.a = move_toward(modulate.a, 0, delta * remove_multiplier)
	if modulate.a <= 0.05:
		display.active_messages -= 1
		Globals.messages_debug_removed.emit()
		queue_free()
	
	if remove_multiplier == 0.1 and abs(target_position_follow_mouse.y - get_global_mouse_position().y) - 12 / scale.y < 0: position.y = get_global_mouse_position().y - 8 * scale.y


var fade_out_active = false

func _on_cooldown_delay_timeout() -> void:
	fade_out_active = true


func handle_repeats():
	if repeats > 0:
		text = "(%s) " % str(repeats) + message_visible
		display.update_bg(text, id)


var currently_focused : bool = false

func _on_mouse_entered() -> void:
	if message_importance is not String or message_importance == "none":
		animation_player.stop()
		animation_player.play("focus_entered")
	
	currently_focused = true
	
	if not Input.is_action_pressed("LMB") : return
	if display.message_following_mouse_id != -1 and display.message_following_mouse_id != following_mouse_id : return
	
	following_mouse_id = id
	display.message_following_mouse_id = following_mouse_id
	
	scale = target_scale + Vector2(0.5, 0.5)
	position += Vector2(0, -4)
	
	target_position_follow_mouse = Vector2(position.x, position.y + 8)
	
	z_index = 50 * id
	remove_multiplier = 0.1
	
	fade_out_active = false
	c_remove.wait_time = 20
	c_remove.start()

func _on_mouse_exited() -> void:
	currently_focused = false
	
	if display.message_following_mouse_id != -1 and display.message_following_mouse_id != following_mouse_id : return
	elif display.message_following_mouse_id == following_mouse_id:
		following_mouse_id = -1
		display.message_following_mouse_id = -1
	
	if float(message_scale) != -1.0 : scale = Vector2(float(message_scale), float(message_scale))
	else : scale = target_scale
	
	position = target_position
	
	display.correct_messages_order()
	
	if message_importance is not String or message_importance == "none":
		animation_player.stop()
		animation_player.play("focus_exited")
	
	z_index = 0
	remove_multiplier = 0.2
	
	fade_out_active = false
	c_remove.wait_time = 4
	c_remove.start()


func set_remove_cooldown(cooldown : float = 10.0):
	fade_out_active = false
	c_remove.wait_time = cooldown
	c_remove.start()
	animation_player.stop()
	
	if message_importance is not String or message_importance == "none" : animation_player.play("focus_entered")
