extends menu_general

@onready var entity_editor : Node = get_parent().get_parent()

@onready var btn_increase: Button = $container_buttons/btn_increase
@onready var btn_decrease: Button = $container_buttons/btn_decrease

@onready var debug_property_name: Label = $debug_property_name
@onready var behavior_icon: Sprite2D = $behavior_icon
@onready var cooldown_show_behavior_name: Timer = $cooldown_show_behavior_name
@onready var cooldown_show_behavior_value: Timer = $cooldown_show_behavior_value
@onready var tm_behavior_name: Control = $container_text_managers/tm_behavior_name
@onready var tm_behavior_value: Control = $container_text_managers/tm_behavior_value

var behavior_name_visible = false
var behavior_value_visible = false


# Property-related info: - [START]
var property_name = "none"
var property_number = -1 # The position of this button's assigned property name, within the list (Array) containing every single property available in the entity editor. It's used for quicker loading of things, like the matching icon image, or module cost.

var behavior_info : Dictionary = {} # The behavior button is given the proper value by the entity editor, when it assembles its buttons.

var behavior_name : String = "none"
var behavior_value = -1 # Also acts as the base value.
var behavior_value_step : float = -1
var behavior_value_min : float = -1
var behavior_value_max : float = -1
var behavior_available_options : Array = ["none"]
# Property-related info: - [END]


func _ready() -> void:
	Globals.dm("Applying behavior button's info:", "ORANGE")
	
	for property_name in behavior_info:
		set(property_name, behavior_info[property_name])
		
		Globals.dm(property_name + " : " + str(behavior_info[property_name]), "YELLOW")
	
	
	if Globals.get("entity_editor_icon_" + property_name) : behavior_icon.texture = load(Globals.get("entity_editor_icon_" + property_name))
	
	debug_property_name.text = property_name
	
	on_ready()

func _process(delta: float) -> void:
	if behavior_name_visible : tm_behavior_name.modulate.a = move_toward(tm_behavior_name.modulate.a, 1.0, delta * 1.5)
	else : tm_behavior_name.modulate.a = move_toward(tm_behavior_name.modulate.a, 0.0, delta * 2)
	if behavior_value_visible : tm_behavior_value.modulate.a = move_toward(tm_behavior_value.modulate.a, 1.0, delta)
	else : tm_behavior_value.modulate.a = move_toward(tm_behavior_value.modulate.a, 0.0, delta * 2)


func _on_btn_increase_pressed() -> void:
	property_value_change(1)
	
	Globals.spawn_scenes(self, Globals.scene_effect_oneShot_enemy, 1, Vector2(size / 2), 0.25, Color(-1, 0, -1, 0), Vector2(-0.5, -0.5), 50)
	Globals.spawn_scenes(self, Globals.scene_particle_special, 1, Vector2(size / 2), 4.0, Color(0, 0, 0, 0), Vector2(0, 0), 51)
	
	on_property_value_changed()

func _on_btn_decrease_pressed() -> void:
	property_value_change(-1)
	
	Globals.spawn_scenes(self, Globals.scene_effect_oneShot_enemy, 1, Vector2(size / 2), 0.25, Color(0, -1, -1, 0), Vector2(-0.5, -0.5), 50)
	Globals.spawn_scenes(self, Globals.scene_particle_star, 1, Vector2(size / 2), 4.0, Color(0, 0, 0, 0), Vector2(0, 0), 51)
	
	on_property_value_changed()


var is_focused = false

func _on_mouse_entered() -> void:
	is_focused = true
	
	scale = Vector2(1.05, 1.05)
	position += Vector2(-3.2, -3.2)
	cooldown_show_behavior_name.start()
	cooldown_show_behavior_value.start()
	
	debug_property_name.visible = true

func _on_mouse_exited() -> void:
	is_focused = false
	
	scale = Vector2(1, 1)
	position += Vector2(3.2, 3.2)
	cooldown_show_behavior_name.stop()
	cooldown_show_behavior_value.stop()
	
	await get_tree().create_timer(0.5, true).timeout
	
	behavior_name_visible = false
	behavior_value_visible = false
	cooldown_show_behavior_name.stop()
	cooldown_show_behavior_value.stop()
	
	debug_property_name.visible = false


func _on_cooldown_show_behavior_name_timeout() -> void:
	behavior_name_visible = true

func _on_cooldown_show_behavior_value_timeout() -> void:

	behavior_value_visible = true


func on_property_value_changed():
	tm_behavior_name.text_full = (str("[anim_loop_up_down_slight]" + behavior_name)) # This line is most likely not needed.
	tm_behavior_name.create_message(str("[anim_loop_up_down_slight]" + behavior_name))
	
	tm_behavior_value.text_full = str("[anim_loop_up_down_slight]" + str(behavior_value)) # This line is most likely not needed.
	tm_behavior_value.create_message(str("[anim_loop_up_down_slight]" + str(behavior_value)))
	
	behavior_name_visible = true
	behavior_value_visible = true
	tm_behavior_name.modulate.a = 1.0
	tm_behavior_value.modulate.a = 1.0


func property_value_change(multiplier : float = 1.0):
	if entity_editor.get(property_name) is float or entity_editor.get(property_name) is int:
		entity_editor.set(property_name, entity_editor.get(property_name) + behavior_value_step * multiplier)
	
	if entity_editor.get(property_name) is bool:
		entity_editor.set(property_name, Globals.opposite_bool(entity_editor.get(property_name)))
	
	if entity_editor.get(property_name) is Vector2:
		entity_editor.set(property_name, entity_editor.get(property_name) + Vector2(behavior_value_step, behavior_value_step) * multiplier)
	
	
	# Convert the property value info a "String", that will be displayed in the game.
	if entity_editor.get(property_name) is String:
		if entity_editor.get(property_name).ends_with(".tscn"):
			var scene = load(entity_editor.get(property_name)).instantiate()
			behavior_value = scene.entity_name
			scene.queue_free()
	
	else:
		print(behavior_value)
		print(type_string(typeof(behavior_value)))
		behavior_value = str(entity_editor.get(property_name))
