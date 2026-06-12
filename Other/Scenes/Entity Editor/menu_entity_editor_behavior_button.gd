extends menu_general

@onready var entity_editor : Node

@onready var btn_increase: Button = $container_buttons/btn_increase
@onready var btn_decrease: Button = $container_buttons/btn_decrease
@onready var btn_choice: Button = $container_buttons/btn_choice

@onready var debug_property_name: Label = $debug_property_name
@onready var behavior_icon: Sprite2D = $behavior_icon
@onready var cooldown_show_behavior_name: Timer = $cooldown_show_behavior_name
@onready var cooldown_show_behavior_value: Timer = $cooldown_show_behavior_value

@onready var container_text_managers: Control = $container_text_managers
@onready var tm_behavior_name: Control = $container_text_managers/tm_behavior_name
@onready var tm_behavior_value: Control = $container_text_managers/tm_behavior_value

@onready var animation_entity_editor_general: AnimationPlayer = $behavior_icon/animation_entity_editor_general


@export var rl_pickup : bool = false


var behavior_name_visible = false
var behavior_value_visible = false


# Property-related info: - [START]
var property_name = "none"
var property_value = "none"
var property_number = -1 # The position of this button's assigned property name, within the list (Array) containing every single property available in the entity editor. It's used for quicker loading of things, like the matching icon image, or module cost.

var behavior_info : Dictionary = {} # The behavior button is given the proper value by the entity editor, when it assembles its buttons.

var behavior_name : String = "none"
var behavior_value = -1 # Also acts as the base value.
var behavior_value_step : float = -1
var behavior_value_min : float = -1
var behavior_value_max : float = -1
var behavior_available_options : Array = ["none"]
# Property-related info: - [END]

var behavior_chosen_option = "none"

var on_spawn_delete_if_stuck = true


func _ready() -> void:
	on_ready()
	
	entity_editor = get_tree().get_first_node_in_group("entity_editor")
	
	if rl_pickup:
		handle_rl_pickup()
	
	Globals.dm("Applying behavior button's info:", "ORANGE")
	print("info ", behavior_info)
	
	for property_name in behavior_info:
		set(property_name, behavior_info[property_name])
		
		Globals.dm(property_name + " : " + str(behavior_info[property_name]), "YELLOW")
	
	if Globals.get("entity_editor_icon_" + property_name) : behavior_icon.texture = load(Globals.get("entity_editor_icon_" + property_name))
	
	if type != "Array_choice":
		tm_behavior_name.text_full = (str("[anim_loop_up_down_slight]" + behavior_name)) # This line is most likely not needed.
		tm_behavior_name.create_message(str("[anim_loop_up_down_slight]" + behavior_name))
		
		tm_behavior_value.text_full = str("[anim_loop_up_down_slight]" + str(behavior_value)) # This line is most likely not needed.
		tm_behavior_value.create_message(str("[anim_loop_up_down_slight]" + str(behavior_value)))
		
		debug_property_name.text = property_name

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("0") : queue_free()
	
	if type != "Array_choice":
		if behavior_name_visible : tm_behavior_name.modulate.a = move_toward(tm_behavior_name.modulate.a, 1.0, delta * 1.5)
		else : tm_behavior_name.modulate.a = move_toward(tm_behavior_name.modulate.a, 0.0, delta * 2)
		if behavior_value_visible : tm_behavior_value.modulate.a = move_toward(tm_behavior_value.modulate.a, 1.0, delta)
		else : tm_behavior_value.modulate.a = move_toward(tm_behavior_value.modulate.a, 0.0, delta * 2)
		
		behavior_icon.modulate.a = move_toward(behavior_icon.modulate.a, 1.0, delta / 2)
		behavior_icon.modulate.r = move_toward(behavior_icon.modulate.r, 1.0, delta / 2)
		behavior_icon.modulate.g = move_toward(behavior_icon.modulate.g, 1.0, delta / 2)
		behavior_icon.modulate.b = move_toward(behavior_icon.modulate.b, 1.0, delta / 2)


func _on_btn_increase_pressed() -> void:
	property_value_change(1)
	
	Globals.spawn_scenes(self, Globals.scene_effect_oneShot_enemy, 1, Vector2(size / 2), 0.25, Color(-1, 0, -1, 0), Vector2(-0.5, -0.5), 50)
	Globals.spawn_scenes(self, Globals.scene_particle_special, 1, Vector2(size / 2), 4.0, Color(0, 0, 0, 0), Vector2(0, 0), 51)
	
	on_property_value_changed(1)

func _on_btn_decrease_pressed() -> void:
	property_value_change(-1)
	
	Globals.spawn_scenes(self, Globals.scene_effect_oneShot_enemy, 1, Vector2(size / 2), 0.25, Color(0, -1, -1, 0), Vector2(-0.5, -0.5), 50)
	Globals.spawn_scenes(self, Globals.scene_particle_star, 1, Vector2(size / 2), 4.0, Color(0, 0, 0, 0), Vector2(0, 0), 51)
	
	on_property_value_changed(-1)


func _on_mouse_entered() -> void:
	is_focused = true
	
	behavior_icon.scale = Vector2(1.05, 1.05)
	cooldown_show_behavior_name.start()
	cooldown_show_behavior_value.start()
	
	debug_property_name.visible = true

func _on_mouse_exited() -> void:
	is_focused = false
	
	behavior_icon.scale = Vector2(1, 1)
	cooldown_show_behavior_name.stop()
	cooldown_show_behavior_value.stop()
	
	behavior_name_visible = false
	behavior_value_visible = false
	cooldown_show_behavior_name.stop()
	cooldown_show_behavior_value.stop()
	
	debug_property_name.visible = false


func _on_cooldown_show_behavior_name_timeout() -> void:
	behavior_name_visible = true

func _on_cooldown_show_behavior_value_timeout() -> void:

	behavior_value_visible = true


func on_property_value_changed(multiplier : float = 1.0):
	if behavior_value is String:
		# Convert the property value info a "String", that will be displayed in the game.
		if Globals.entity_editor_preview.get(property_name).ends_with(".tscn"):
			var scene = load(Globals.get(property_name)).instantiate()
			behavior_value = scene.entity_name
			scene.queue_free()
	
	elif behavior_value is bool:
		if behavior_value : behavior_value = "Yes."
		else : behavior_value = "No."
	
	tm_behavior_name.queue_free()
	tm_behavior_name = load("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn").instantiate()
	tm_behavior_name.character_bg_simple = true
	tm_behavior_name.size = Vector2(512, 64)
	container_text_managers.add_child(tm_behavior_name)
	
	tm_behavior_value.queue_free()
	tm_behavior_value = load("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn").instantiate()
	tm_behavior_value.character_bg_simple = true
	tm_behavior_value.position.y = 64
	tm_behavior_value.size = Vector2(512, 64)
	container_text_managers.add_child(tm_behavior_value)
	
	tm_behavior_name.text_full = (str("[anim_loop_up_down_slight]" + behavior_name)) # This line is most likely not needed.
	tm_behavior_name.create_message(str("[anim_loop_up_down_slight]" + behavior_name))
	
	tm_behavior_value.text_full = str("[anim_loop_up_down_slight]" + str(behavior_value)) # This line is most likely not needed.
	tm_behavior_value.create_message(str("[anim_loop_up_down_slight]" + str(behavior_value)))
	
	behavior_name_visible = true
	behavior_value_visible = true
	tm_behavior_name.modulate.a = 1.0
	tm_behavior_value.modulate.a = 1.0
	
	animation_entity_editor_general.stop()
	
	if type == "int_float":
		animation_entity_editor_general.speed_scale = 2
		if multiplier > 0 : animation_entity_editor_general.play("scale_down_up")
		else : animation_entity_editor_general.play("scale_up_down")
		behavior_icon.modulate = Color(1.5, 1.5, 1.5, 1)
	if type == "bool":
		animation_entity_editor_general.speed_scale = 2
		animation_entity_editor_general.play("rotate_z")
		if property_value : behavior_icon.modulate = Color(0, 1, 0, 1)
		else : behavior_icon.modulate = Color(1, 0, 0, 1)
	if type == "Array":
		animation_entity_editor_general.play("scale_down_up_and_rotate")
	
	Globals.update_entity()


func property_value_change(multiplier : float = 1.0):
	print("name: " + property_name)
	print(Globals.entity_editor_preview.get(property_name))
	if Globals.entity_editor_preview.get(property_name) is float or Globals.entity_editor_preview.get(property_name) is int:
		Globals.entity_editor_preview.set(property_name, clamp(Globals.entity_editor_preview.get(property_name) + behavior_value_step * multiplier, behavior_value_min, behavior_value_max))
	
	elif Globals.entity_editor_preview.get(property_name) is bool:
		Globals.entity_editor_preview.set(property_name, Globals.opposite_bool(Globals.entity_editor_preview.get(property_name)))
	
	elif Globals.entity_editor_preview.get(property_name) is Vector2:
		Globals.entity_editor_preview.set(property_name, Globals.entity_editor_preview.get(property_name) + Vector2(behavior_value_step, behavior_value_step) * multiplier)
	
	elif Globals.entity_editor_preview.get(property_name) is String:
		pass # The "one of multiple options within an Array" (like a scene filepath) type of property value is set (with the use of "apply_chosen_option()") by behavior buttons within a completely different menu, dedicated to Arrays.
	
	elif Globals.entity_editor_preview.get(property_name) is Array:
		if "range" in property_name:
			Globals.entity_editor_preview.set(property_name[0], Globals.entity_editor_preview.get(property_name)[0] + Vector2(behavior_value_step, behavior_value_step) * multiplier)
			Globals.entity_editor_preview.set(property_name[1], Globals.entity_editor_preview.get(property_name)[1] + Vector2(behavior_value_step, behavior_value_step) * multiplier)
	
	behavior_value = Globals.entity_editor_preview.get(property_name)
	print(behavior_value)
	print(behavior_info)
	
	Globals.update_entity()


func _on_btn_show_available_pressed() -> void:
	var menu_choices = load(Globals.scene_menu_entity_editor_choices).instantiate()
	Overlay.add_child(menu_choices)
	
	for choice in behavior_info["behavior_available_options"]:
		
		var button_choice = load(Globals.scene_ui_button_general_entity_editor_choice).instantiate()
		
		button_choice.choice = choice
		button_choice.target_node = self
		button_choice.adjust_decoration_position = true
		
		menu_choices.container_buttons.add_child(button_choice)


func _on_btn_close_pressed() -> void:
	queue_free()


func apply_chosen_option():
	behavior_value = behavior_chosen_option
	Globals.set(property_name, behavior_value)
	on_property_value_changed()


func _on_btn_toggle_pressed() -> void:
	property_value = Globals.opposite_bool(Globals.entity_editor_preview.get(property_name))
	behavior_value = property_value
	Globals.entity_editor_preview.set(property_name, property_value)
	on_property_value_changed()


func handle_rl_pickup():
	z_index += 100
	
	property_name = Globals.l_available_property_name.pick_random()
	behavior_info = Globals.get("l_" + property_name + "_button_info")
	
	if type == "bool":
		pass


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not Globals.is_valid_entity(area) : return
	
	Globals.weapon_main_unlocks[property_name][0] = true
	
	Globals.spawn_scenes(Globals.World, Globals.scene_particle_special, 10, position + size / 2)
	Globals.message("New weapon module unlocked! Press Q to open the projectile editor.")
	queue_free()
