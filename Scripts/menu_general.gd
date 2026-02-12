class_name menu_general
extends Control

# Note: The Level Set screen reuses "menu_main", with more buttons disabled (using exported properties), unlike the settings menu. The reason is that unlike Settings, the Level Set screen doesn't require many buttons, and all of the needed ones overlap with the Main Menu anyway.

@onready var container_buttons = $container_buttons # It is crucial to add a container node to the menu core for the menu to work. It's not added by default only because it would limit the type of container used, to just one (nodes in inherited scenes do not allow you to change their type).

@onready var t_destabilized: Timer = $timer_destabilized
@onready var c_toggle_button_destabilize_modulate_reversed: Timer = $cooldown_toggle_button_destabilize_modulate_reversed

@onready var debug_real_size_container_buttons: ColorRect = $debug_real_size_container_buttons

@export var randomize_default_preset : bool = true

var l_destabilize_type = ["pos_x", "pos_y", "pos_xy", "rotation", "scale"]

var ready_show = false
var button_quantity : int = 0

@export var l_disable_buttons : Array = ["none"]

var button_color : String = "none"


func _ready() -> void:
	on_ready()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("0"):
		queue_free()
	
	#debug_real_size_container_buttons.position = container_buttons.position
	#debug_real_size_container_buttons.size = container_buttons.size

func on_ready():
	#Globals.gameState_changed.connect(delete_menu)
	
	Globals.debug4.connect(debug_destabilize_buttons_randomize)
	
	disable_buttons()
	
	button_color = Globals.l_color.pick_random()
	
	modulate.a = 0.0
	
	for button in container_buttons.get_children():
		button.button_ready.connect(on_button_ready)
	
	await get_tree().create_timer(0.1, true).timeout
	
	adjust_buttons()
	
	ready_show = true
	modulate.a = 1.0
	
	if Globals.debug_mode : $debug_real_size_container_buttons.visible = true


# This function is executed right after a menu gets the final "button_ready" signal. The needed amount is equal to total button count in a given menu. Note: It's called from within the "on_button_ready()" function.
func destabilize_buttons_randomize(d_pos_x : bool = true, d_pos_y : bool = true, d_pos_range_x : int = 8000, d_pos_range_y : int = 4000, d_rotation : bool = true, d_rotation_range : int = 360, d_scale_x : bool = true, d_scale_y : bool = true, d_scale_match : bool = true, d_scale_range_x : float = 40, d_scale_range_y : float = 0): # The "d" stands for "destabilize".
	Globals.message_debug("Destabilizing buttons (d_pos_x = " + str(d_pos_x) + ", " + "d_pos_y = " + str(d_pos_y) + ", " + "d_pos_range_x = " + str(d_pos_range_x) + ", " + "d_pos_range_y = " + str(d_pos_range_y) + ", " + "d_rotation = " + str(d_rotation) + ", " + "d_rotation_range = " + str(d_rotation_range) + ", " + "d_scale_x = " + str(d_scale_x) + ", " + "d_scale_y = " + str(d_scale_y) + "," + "d_scale_match = " + str(d_scale_match) + ", " + "d_scale_range_x = " + str(d_scale_range_x) + ", " + "d_scale_range_y = " + str(d_scale_range_y) + ".")
	t_destabilized.start()
	
	var destabilize_type : String = "none"
	
	# Some destabilization types are supposed to be more rare than the rest. Below is the mechanism doing that.
	Globals.message_debug("Choosing a valid button destabilization type...")
	var valid : bool = false
	while not valid:
		
		destabilize_type = l_destabilize_type.pick_random()
		
		if destabilize_type == "pos_y" or destabilize_type == "pos_xy":
			Globals.message_debug(str("Rolled an uncommon destabilization type (%s). There is now a 50 percent chance for it to be considered valid." % str(destabilize_type)), 1)
			if randi_range(0, 20) > 10 : valid = false ; Globals.message_debug("The 50 percent chance roll has failed. Retrying...", 2)
			else : valid = true ; Globals.message_debug("The 25 percent chance roll has succeeded.", 1)
			
		else:
			valid = true
			Globals.message_debug(str("Rolled a common destabilization type (%s)." % destabilize_type))
	
	
	for button in container_buttons.get_children():
		if button.is_in_group("UI_button"):
			
			button.stabilized = false
			button.stabilize_multiplier = 0.1
			
			button.decoration.modulate.a = 0.0
			button.pivot_offset = Vector2(randf_range(-button.decoration.size.x, button.decoration.size.x), randf_range(-button.decoration.size.y, button.decoration.size.y))
			
			Globals.message_debug("The current Menu Button destabilization type is %s." % destabilize_type)
			
			if destabilize_type == "pos_x":
				if d_pos_x:
					button.position.x += randi_range(-d_pos_range_x, d_pos_range_x) * 2
			
			if destabilize_type == "pos_y":
				if d_pos_y:
					button.position.y += randi_range(-d_pos_range_y, d_pos_range_y) * 2
			
			if destabilize_type == "pos_xy":
				
				destabilize_pos(button, d_pos_x, d_pos_y, d_pos_range_x, d_pos_range_y)
			
			elif destabilize_type == "rotation":
				
				button.pivot_offset *= Vector2(randf_range(-2, 2), randf_range(-2, 2))
				destabilize_pos(button, d_pos_x, d_pos_y, d_pos_range_x, d_pos_range_y)
				
				if d_rotation:
					button.rotation_degrees += randi_range(-d_rotation_range * 2, d_rotation_range * 2)
			
			elif destabilize_type == "scale":
				
				button.pivot_offset *= Vector2(randf_range(-4, 4), randf_range(-4, 4))
				destabilize_pos(button, d_pos_x, d_pos_y, d_pos_range_x, d_pos_range_y)
				
				if d_scale_match:
					
					if d_scale_x:
						button.scale.x += randf_range(0, d_scale_range_x)
						
					if d_scale_y:
						button.scale.y = button.scale.x
				
				else:
					button.scale += Vector2(randf_range(0, d_scale_range_x), randf_range(0, d_scale_range_y))

func destabilize_pos(button, d_pos_x, d_pos_y, d_pos_range_x, d_pos_range_y):
	if d_pos_x:
		button.position.x += randi_range(-d_pos_range_x, d_pos_range_x)
		
	if d_pos_y:
		button.position.y += randi_range(-d_pos_range_y, d_pos_range_y)


func _on_timer_destabilized_timeout() -> void:
	for button in container_buttons.get_children():
		if button.is_in_group("UI_button"):
			
			button.id = button.get_index() + 1
			
			button.stabilized = true
			button.stabilize_multiplier = 0.1
			
			if abs(button.target_pos) - abs(button.position) < Vector2(1.0, 1.0):
				button.position = button.target_pos
				button.rotation_degrees = button.target_rotation
				button.scale = button.target_scale
				
				if Globals.debug_mode:
					button.debug_show_real_size(false)
					button.get_node("%debug_pos").modulate = Color.GREEN_YELLOW
					button.get_node("%debug_target_pos").modulate = Color.GREEN_YELLOW
					button.get_node("%debug_original_pos").modulate = Color.GREEN_YELLOW
	
	Globals.dm("Menu buttons are no longer destabilized.")


var ready_buttons = 0

func on_button_ready():
	ready_buttons += 1
	
	Globals.message_debug(str("Ready menu buttons: %s/%s" % [ready_buttons, len(container_buttons.get_children())]))
	if ready_buttons == len(container_buttons.get_children()):
		if randomize_default_preset : destabilize_buttons_randomize() # No arguments means: "default preset".
		ready_buttons = 0

var debug_available = true

func _on_cooldown_debug_available_timeout() -> void:
	debug_available = true


func debug_destabilize_buttons_randomize():
	if not debug_available : return
	
	for button in container_buttons.get_children():
		button.get_node("%debug_pos").modulate = Color.WHITE
		button.get_node("%debug_target_pos").modulate = Color.WHITE
		button.get_node("%debug_original_pos").modulate = Color.WHITE
	
	destabilize_buttons_randomize()
	
	$debug_real_size_container_buttons.visible = Globals.opposite_bool($debug_real_size_container_buttons.visible)
	
	debug_available = false
	$cooldown_debug_available.start()


func _on_enable_score_attack_mode_pressed():
	if Globals.mode_scoreAttack == false:
		Globals.mode_scoreAttack = true
		$"menu_main/menu_container/Control/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Disable Score Attack Mode[/wave]"
		
	elif Globals.mode_scoreAttack == true:
		Globals.mode_scoreAttack = false
		$"menu_main/menu_container/Control/Enable Score Attack Mode/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Enable Score Attack Mode[/wave]"

func _on_timer_buttons_blocked_timeout() -> void:
	buttons_blocked = false
	Globals.message_debug("Menu buttons are no longer blocked.")


#func place_level_icons(levelSet_id):
	#var level_number = 0
	#for icon in range(1, SaveData.get("info_" + levelSet_id)[1]):
		#level_number += 1
		#
		#var level_icon = Globals.scene_levelSet_level_icon.instantiate()
		#level_icon.level_number = level_number
		#$level_icon_container.add_child(level_icon)


@onready var timer_buttons_blocked: Timer = $timer_buttons_blocked
var buttons_blocked = false

func check_buttons_blocked(p_block_buttons_time):
	if buttons_blocked:
		Globals.message_debug("Clicked a menu button but the menu buttons were blocked at the time.")
		return true
	
	if p_block_buttons_time: # Won't execute if the value is equal to "0.0".
		buttons_blocked = true
		timer_buttons_blocked.wait_time = p_block_buttons_time
		timer_buttons_blocked.start()
	
	return false


# On menu button pressed - [START]

# MAIN MENU - [START]
func handle_button_pressed_general(p_block_buttons_time): # The "p" stands for "passed".
	if check_buttons_blocked(p_block_buttons_time) : return true


func _on_btn_resume_game_pressed(block_buttons_time : float = 1.0) -> void:
	if handle_button_pressed_general(block_buttons_time) : return
	
	Globals.handle_pause()

func _on_btn_level_set_screen_pressed(block_buttons_time : float = 1.0) -> void:
	if handle_button_pressed_general(block_buttons_time) : return
	
	Globals.change_main_scene(Globals.scene_levelSet_screen)

func _on_btn_back_to_overworld_pressed(block_buttons_time : float = 1.0) -> void:
	if handle_button_pressed_general(block_buttons_time) : return
	
	var saved_level = SaveData.saved_last_level_filepath
	
	#DEBUG
	if saved_level == "none":
		saved_level = "res://Levels/overworld_infected_glades.tscn"
	
	Overlay.animation("black_fade_in", 1.0, false, true)
	Globals.transition_triggered = false
	get_tree().change_scene_to_packed(load(saved_level))

func _on_btn_enable_score_attack_mode_pressed(block_buttons_time : float = 1.0) -> void: # The argument here is useless, and can be safely replaced by any float value in each "_on_btn_[button]_pressed" function.
	if handle_button_pressed_general(block_buttons_time) : return

func _on_btn_settings_pressed(block_buttons_time : float = 1.0) -> void:
	if handle_button_pressed_general(block_buttons_time) : return

func _on_btn_quit_to_main_menu_pressed(block_buttons_time : float = 1.0) -> void:
	if handle_button_pressed_general(block_buttons_time) : return
	
	Globals.change_main_scene(Globals.scene_start_screen)

func _on_btn_quit_game_pressed(block_buttons_time : float = 1.0) -> void:
	if handle_button_pressed_general(block_buttons_time) : return
	
	Overlay.animation("black_fade_in", 0.5, false, true)
	get_tree().quit()

func _on_btn_start_new_game_pressed(block_buttons_time : float = 1.0) -> void:
	SaveData.wipe_slot(SaveData.slot_current)
	Globals.change_main_scene(Globals.scene_start_area)

func _on_btn_continue_pressed(block_buttons_time : float = 1.0) -> void:
	pass # Replace with function body.

func _on_btn_select_level_set_pressed(block_buttons_time : float = 1.0) -> void:
	Globals.spawn_menu(Globals.scene_menu_select_levelSet, [], Globals.window_size / 2)
	queue_free()

# MAIN MENU - [END]

# SETTINGS MENU - [START]

func _on_btn_video_pressed() -> void:
	pass # Replace with function body.


func _on_btn_sound_pressed() -> void:
	pass # Replace with function body.


func _on_btn_gameplay_pressed() -> void:
	pass # Replace with function body.


func _on_btn_accessibility_pressed() -> void:
	pass # Replace with function body.


func _on_btn_return_settings_pressed() -> void:
	Globals.spawn_menu(["Start New Game"])
	queue_free()

# SETTINGS MENU - [END]

# On menu button pressed - [END]


func disable_buttons():
	for button_name in l_disable_buttons:
		for button in container_buttons.get_children():
			if button.name == button_name or button.name == "btn_" + button_name:
				Globals.message_debug(str("Removing the %s button from a menu." % button_name))
				button.queue_free()


var button_size_multiplier = Vector2(1, 1)

func adjust_buttons():
	await get_tree().create_timer(0.1, true).timeout
	for button in container_buttons.get_children():
		adjust_buttons_general(button)
	
	await get_tree().create_timer(0.1, true).timeout
	for edge in get_tree().get_nodes_in_group("UI_button_general_decoration_right"):
		adjust_buttons_edge(edge)

func adjust_buttons_general(button):
	button.custom_minimum_size.y *= button_size_multiplier.y
	button.size.y *= button_size_multiplier.y
	if button_size_multiplier != Vector2(1, 1) : button.target_pos *= button_size_multiplier * 1.2
	button.decoration.custom_minimum_size.y *= button_size_multiplier.y
	button.decoration.size.y *= button_size_multiplier.y

func adjust_buttons_edge(edge):
	Globals.message_debug("Adjusting Button Decoration's right edge.")
	edge.size.y *= button_size_multiplier.y


func _on_cooldown_toggle_button_destabilize_modulate_reversed_timeout() -> void:
	Globals.message_debug("Reversing Button Decoration's color blend order and possibly choosing a different menu button color.")
	
	if randi_range(-1, 1) : button_color = Globals.l_color.pick_random()
	
	var toggle_button_destabilize_modulate_dark = true
	if randi_range(-1, 1) : toggle_button_destabilize_modulate_dark = false
	
	for button in container_buttons.get_children():
		button.button_destabilize_modulate_reversed = Globals.opposite_bool(button.button_destabilize_modulate_reversed)
		button.button_destabilize_modulate_dark = toggle_button_destabilize_modulate_dark


func delete_menu(): # Will add some menu deletion effect making heavy use of the general tween tool (doesn't exist yet) for each button.
	queue_free()
