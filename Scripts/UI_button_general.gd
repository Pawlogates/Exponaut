extends Button

var remove = false # Decides whether this button will appear in a spawned general menu.

var button_levelSet_id = "none"
var button_levelSet_name = "none"

signal button_clicked

@onready var button_container : VBoxContainer = get_parent()
@onready var menu : Control = button_container.get_parent()

@onready var decoration: Button = $decoration
@onready var text_manager: Control = $text_manager
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cooldown_active: Timer = $cooldown_active
@onready var sfx_stabilize: AudioStreamPlayer2D = $sfx_stabilize
@onready var sfx_focused: AudioStreamPlayer2D = $sfx_focused
@onready var sfx_clicked: AudioStreamPlayer2D = $sfx_clicked

@export var text_manager_message = "none"
@export var text_manager_letter_alignment = 0
@export var text_manager_letter_animation_sync = true
@export var text_manager_cooldown_create_message : float = -1.0

@export var decoration_base_size = Vector2(720, 64)
@export var decoration_base_size_multiplier = Vector2(1.0, 1.0)
@export var decoration_base_scale = Vector2(1, 1)
@export var decoration_base_rotation = 1
@export var decoration_base_position = Vector2(0, 0)

var is_pressed = false
var is_focused = false

var on_focus_rotation_direction = 1

var enabled = true # Decides whether it can interact with the mouse.
var active = false # Only used for visual behavior.

var stabilized : bool = true # It is true when the button decoration is in the middle of a transition animation. Note that this property is usually changed by a Menu and not the button itself.

var target_pos = Vector2(0, 0)
var target_rotation = 0.0
var target_scale = Vector2(0, 0)

var original_pos = Vector2(0, 0)
var original_rotation = 0.0
var original_scale = Vector2(0, 0)

signal button_ready

var id : int = 0

var stabilize_multiplier = 1.0
var button_destabilize_modulate_reversed = false
var button_destabilize_modulate_dark = false

var debug_markers : Array

var button_quantity : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if remove : queue_free() ; return
	
	Globals.message_debug("Connecting debug signal 1 to a General UI Button, with the target function being 'debug_refresh_decoration'.")
	Globals.debug1.connect(debug_refresh_decoration)
	Globals.message_debug("Connecting debug signal 2 to a General UI Button, with the target function being 'debug_show_real_size'.")
	Globals.debug2.connect(debug_show_real_size)
	Globals.refreshed2_0.connect(on_refreshed2_0)
	
	mouse_filter = 0
	decoration.mouse_filter = 0
	
	id = get_index() + 1
	menu.button_quantity += 1
	
	stabilize_multiplier = -0.5 # This causes the button to be invisible until about when its been destabilized.
	
	text_manager.text_alignment = text_manager_letter_alignment
	text_manager.text_animation_sync = text_manager_letter_animation_sync
	
	if text_manager_cooldown_create_message != -1.0:
		text_manager.cooldown_create_message = text_manager_cooldown_create_message
	else:
		text_manager.cooldown_create_message = randf_range(0.25, 1)
	
	text_manager.create_message(text_manager_message)
	Globals.message_debug("Text Manager message has been requested by a Button.")
	
	decoration.modulate.a = 0.0
	
	await get_tree().create_timer(0.1, true).timeout
	
	spawn_decoration()
	sfx_random()
	
	await get_tree().create_timer(1.0, true).timeout
	
	mouse_filter = 1
	decoration.mouse_filter = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if correct_pivot_offset or is_focused : decoration.pivot_offset = decoration.size / 2
	
	if active:
		decoration.rotation_degrees = lerp(decoration.rotation_degrees, 2.0 * on_focus_rotation_direction, delta * 10)
		decoration.scale = lerp(decoration.scale, decoration_base_scale * Vector2(1.1, 1.1), delta * 20)
	else:
		decoration.rotation_degrees = lerp(decoration.rotation_degrees, 0.0, delta * 20)
		decoration.scale = lerp(decoration.scale, decoration_base_scale, delta * 20)
	
	var previous_opacity = decoration.modulate.a
	
	if not stabilized:
		position = lerp(position, target_pos, delta * stabilize_multiplier)
		rotation_degrees = lerp(rotation_degrees, target_rotation, delta * stabilize_multiplier)
		scale = lerp(scale, target_scale, delta * stabilize_multiplier)
		
		stabilize_multiplier = move_toward(stabilize_multiplier, 5.0, delta * 20)
	
	
	elif menu.button_color != "none":
		if button_destabilize_modulate_reversed:
			#print(delta / id * 4)
			if button_destabilize_modulate_dark:
				decoration.modulate = lerp(decoration.modulate, Color(1, 1, 1, 1).blend(Color((button_quantity - id) * 0.1, (button_quantity - id) * 0.1, (button_quantity - id) * 0.1, 1.0) * Color(menu.button_color) + Color(0.85, 0.85, 0.85, 1.0)), delta / clampf(button_quantity - id, 0.5, 100) * 2)
			else:
				decoration.modulate = lerp(decoration.modulate, Color(1, 1, 1, 1).blend(Color((button_quantity - id) * 0.1, (button_quantity - id) * 0.1, (button_quantity - id) * 0.1, 1.0) * Color(menu.button_color) + Color(1.0, 1.0, 1.0, 1.0)), delta / clampf(button_quantity - id, 0.5, 100) * 2)
		else:
			#print(delta / (button_quantity - id - 1) * 4)
			#print(clampf(button_quantity - id, 0.5, 100), " ", delta)
			if button_destabilize_modulate_dark:
				decoration.modulate = lerp(decoration.modulate, Color(1, 1, 1, 1).blend(Color(id * 0.1, id * 0.1, id * 0.1, 1.0) * Color(menu.button_color) + Color(0.85, 0.85, 0.85, 1.0)), delta / id * 2)
			else:
				decoration.modulate = lerp(decoration.modulate, Color(1, 1, 1, 1).blend(Color(id * 0.1, id * 0.1, id * 0.1, 1.0) * Color(menu.button_color) + Color(1.0, 1.0, 1.0, 1.0)), delta / id * 2)
	
	
	decoration.modulate.a = previous_opacity
	decoration.modulate.a = move_toward(decoration.modulate.a, 1.0, delta * stabilize_multiplier)


func spawn_decoration(debug : bool = false):
	if not debug:
		await get_tree().create_timer(0.05, true).timeout
		adjust_decoration()
		await get_tree().create_timer(0.05, true).timeout
		spawn_decoration_gears(false)
		await get_tree().create_timer(0.05, true).timeout
		spawn_decoration_edges(false)
		
		button_ready.emit()
		button_quantity = menu.button_quantity
	
	else:
		await get_tree().create_timer(0.05, true).timeout
		adjust_decoration()
		await get_tree().create_timer(0.05, true).timeout
		spawn_decoration_gears(true)
		await get_tree().create_timer(0.05, true).timeout
		spawn_decoration_edges(true)


func _on_button_down() -> void:
	if not enabled : return
	
	is_pressed = true


func _on_button_up() -> void:
	is_pressed = false
	
	animation_player.play("clicked")
	button_clicked.emit()
	
	sfx_clicked.play()


func _on_focus_entered() -> void: # Note: This does NOT trigger on hovering over the button with mouse.
	if not enabled : return
	
	is_focused = true
	
	cooldown_active.start()
	
	sfx_focused.pitch_scale = randf_range(0.8, 1.2)
	sfx_focused.play()


func _on_focus_exited() -> void:
	is_focused = false
	
	active = false # This is needed so that the rotation animation doesnt start too quickly/often.
	cooldown_active.stop()


func _on_mouse_entered() -> void: # This does trigger on hovering over the button with mouse...
	if not enabled : return
	
	is_focused = true
	
	cooldown_active.start()
	
	animation_player.stop()
	animation_player.speed_scale = 4.0
	animation_player.play("focused")
	
	sfx_focused.pitch_scale = randf_range(0.8, 1.2)
	sfx_focused.play()


func _on_mouse_exited() -> void:
	is_focused = false
	
	active = false
	cooldown_active.stop()


var correct_pivot_offset = false

func _on_animation_player_current_animation_changed(name: String) -> void:
	correct_pivot_offset = true


var gear_fail_chance = 0.999

func spawn_decoration_gears(delete_old : bool = true):
	if delete_old:
		Globals.message_debug("Deleting old button decorations.")
		for node in decoration.get_children():
			if "type" in node:
				if node.type == "gear":
					node.queue_free()
	
	else:
		Globals.message_debug("Leaving old button decorations.")
	
	for x in range(int(decoration.size.x)):
		
		if Globals.debug_mode:
			debug_place_markers(x)
		
		if randf_range(0, int(decoration.size.x)) > int(decoration.size.x) * gear_fail_chance:
			
			var button_bg_position_x = (get_parent().size.x - decoration.size.x) / 2
			
			var deco_core = Globals.scene_decoration_core.instantiate()
			
			deco_core.position.x += x
			deco_core.scale.x = randf_range(0.25, 1.25) / 4
			deco_core.scale.y = deco_core.scale.x
			
			if x <= 256 * deco_core.scale.x:
				
				if x <= 128 * deco_core.scale.x:
					deco_core.is_near_edge = -2
				elif x <= 64 * deco_core.scale.x:
					deco_core.is_near_edge = -4
				else:
					deco_core.is_near_edge = -1 # Because the only option left is: "x <= 256 * deco_core.scale.x"
				
				if Globals.debug_mode : Globals.spawn_scenes(self, Globals.scene_effect_dust, 1, Vector2(x + button_bg_position_x, 32), 2, Color(1, 0, 1, 1), Vector2(0, 0), 250)
			
			elif x >= decoration.size.x - 256 * deco_core.scale.x:
				
				if x >= decoration.size.x - 128 * deco_core.scale.x:
					deco_core.is_near_edge = 2
				elif x >= decoration.size.x - 64 * deco_core.scale.x:
					deco_core.is_near_edge = 4
				else:
					deco_core.is_near_edge = 1 # Because the only option left is: "x >= decoration.size.x - 256 * deco_core.scale.x"
				
				if Globals.debug_mode : Globals.spawn_scenes(self, Globals.scene_effect_dust, 1, Vector2(x + button_bg_position_x, 32), 2, Color(1, 1, 0, 1), Vector2(0, 0), 250)
			
			var scene = Globals.scene_gear
			
			var rolled_gear_type_id = randi_range(1, 5)
			if rolled_gear_type_id == 1: # Because there is no "gear1.tscn" scene.
				scene = Globals.scene_gear
			else:
				scene = Globals.get("scene_gear" + str(rolled_gear_type_id))
			
			var gear = scene.instantiate()
			
			if Globals.random_bool(1, 1):
				if Globals.random_bool(3, 1) : deco_core.position.y = 0 + randi_range(-5, 15)
				else : deco_core.position.y = 0
			
			else:
				if Globals.random_bool(3, 1) : deco_core.position.y = size.y + randi_range(-15, 5)
				else : deco_core.position.y = size.y
			
			deco_core.add_child(gear) # Reparenting is needed for relative position animations.
			decoration.add_child(deco_core)
			
			if Globals.random_bool(1, 12):
				
				if Globals.random_bool(1, 4):
					deco_core.z_index += -5
				else:
					deco_core.z_index += randi_range(-4, 4)
				
				Globals.message_debug("The Z layer value for this button decoration is: " + str(gear.z_index) + ".", 3)
			
			else:
				deco_core.z_index += randi_range(-9, 3)
				Globals.message_debug("The Z layer value for this button decoration is: " + str(gear.z_index) + " (randomized).", 2)
			
			deco_core.randomize_multiplier = 0.15
			deco_core.randomize_multiplier2 = 1.0
			
			deco_core.play_anim(true) # The bool decides whether all of the decoration's animations will be randomized.
			
			Globals.message_debug(str("Spawning gear button decoration... (Chance of success: %s)" % gear_fail_chance))

func spawn_decoration_edges(delete_old : bool = true):
	if delete_old:
		Globals.message_debug("Deleting old button right decorations.")
		for node in decoration.get_children():
			if node.is_in_group("UI_button_general_decoration_right"):
				node.queue_free()
	
	var decoration_right : Node
	
	if Globals.random_bool(1, 1):
		decoration_right = Globals.scene_UI_button_general_decoration_right_round.instantiate()
	else:
		decoration_right = Globals.scene_UI_button_general_decoration_right_slope.instantiate()
	
	decoration_right.position = Vector2(decoration.size.x - 2, 0)
	
	decoration.add_child(decoration_right)

func adjust_decoration():
	pivot_offset = size / 2
	
	decoration.size = decoration_base_size * decoration_base_size_multiplier
	decoration.size.x *= randf_range(0.9, 1.1)
	decoration.pivot_offset = decoration.size / 2
	decoration.position = Vector2(0, 0)
	decoration.position.x += (get_parent().size.x - decoration.size.x) / 2
	decoration.scale = decoration_base_scale
	
	original_pos = position
	original_rotation = rotation_degrees
	original_scale = scale
	
	target_pos = original_pos
	target_rotation = original_rotation
	target_scale = original_scale


func _on_cooldown_active_timeout() -> void:
	active = true
	
	on_focus_rotation_direction = randi_range(-1, 1)
	
	while not on_focus_rotation_direction: # Restart if rolled direction is equal to 0.
		on_focus_rotation_direction = randi_range(-1, 1)


func debug_refresh_decoration():
	if not debug_available : return
	
	spawn_decoration(true)
	
	debug_available = false
	$cooldown_debug_available.start()
	
	Globals.message_debug("DEBUG - Refreshed button decoration.", 1)

func debug_show_real_size(toggle_visible : bool = true):
	$debug/debug_real_size.size = size
	$debug/debug_real_size.pivot_offset = pivot_offset
	
	%debug_pos.text = "position = " + str(position)
	%debug_original_pos.text = "original_pos = " + str(original_pos)
	%debug_target_pos.text = "target_pos = " + str(target_pos)
	
	if toggle_visible:
		$debug.visible = Globals.opposite_bool($debug.visible)
		Globals.message_debug("DEBUG - Toggled visibility of a Button's real size, as well as its position values.", 2)


var debug_available = true

func _on_cooldown_debug_available_timeout() -> void:
	debug_available = true


func sfx_random():
	await get_tree().create_timer(randf_range(0.25, 1.0), true).timeout
	
	sfx_stabilize.volume_linear = randf_range(0.25, 2)
	sfx_stabilize.pitch_scale = randf_range(0.75, 1.25)
	sfx_stabilize.stream = Globals.l_sfx_menu_stabilize.pick_random()
	sfx_stabilize.play()
	Globals.message_debug("A button played a sound effect: %s (randomized)." % sfx_stabilize.stream)


func debug_place_markers(x):
	await get_tree().create_timer(0.05 * id, true).timeout
	if x == 0 : Globals.spawn_scenes(self, load("res://Other/Scenes/debug_marker.tscn"), 2, Vector2(x - decoration.size.x / 2 + size.x / 2, decoration.size.y / 2), 2, Color(0, -0.4, 0, 0), Vector2(0, 0), 15)
	elif x == int(decoration.size.x) - 1 : Globals.spawn_scenes(self, load("res://Other/Scenes/debug_marker.tscn"), 2, Vector2(x - decoration.size.x / 2 + size.x / 2, decoration.size.y / 2), 2, Color(0, 0, -0.4, 0), Vector2(0, 0), 15)


func on_refreshed2_0():
	debug_show_real_size(false)
	if Globals.debug_mode : menu.button_color = Globals.l_color.pick_random()
