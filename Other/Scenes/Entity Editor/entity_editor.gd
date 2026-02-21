extends Control

@onready var container_behavior_buttons = $container_behavior_buttons
@onready var bg: ColorRect = $bg


var l_available_property_name = ["speed", "acceleration_multiplier_x", "ignore_gravity", "on_timeout_change_ignore_gravity", "on_timeout_change_ignore_gravity_cooldown", "on_wall_bounce", "on_floor_bounce", "movement_type", "on_death_spawn_entity", "on_death_spawn_entity_scene_filepath", "on_death_spawn_entity_quantity", "on_death_spawn_entity_add_velocity", "on_death_spawn_entity_add_velocity_range", "on_hit_spawn_entity", "on_hit_spawn_entity_scene_filepath", "on_hit_spawn_entity_quantity", "on_hit_spawn_entity_add_velocity", "on_hit_spawn_entity_add_velocity_range", "on_timeout_death", "on_timeout_death_cooldown", "on_spawn_copy_direction_x_player", "on_spawn_copy_direction_x_active_player", "copy_direction_x_player", "copy_direction_x_active_player", "direction_x", "set_player_attack_cooldown_value", "on_spawn_max_speed", "always_max_speed", "breakable"]

var l_speed_button_info : Dictionary = {"behavior_name" : "Movement Speed", "behavior_value" : 500, "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_acceleration_multiplier_x_button_info : Dictionary = {"behavior_name" : "Acceleration", "behavior_value" : 1.0, "behavior_value_step" : 0.1, "behavior_value_min" : 0.25, "behavior_value_max" : 10.0, "behavior_available_options" : ["none"]}

var l_on_wall_bounce_button_info : Dictionary = {"behavior_name" : "Bounce off the ground", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_floor_bounce_button_info : Dictionary = {"behavior_name" : "Bounce off the walls", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}

var l_ignore_gravity_button_info : Dictionary = {"behavior_name" : "Ignore Gravity", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_timeout_change_ignore_gravity_button_info : Dictionary = {"behavior_name" : "Fall after a delay", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_timeout_change_ignore_gravity_cooldown_button_info : Dictionary = {"behavior_name" : "Fall delay", "behavior_value" : 1.0, "behavior_value_step" : 0.25, "behavior_value_min" : 0, "behavior_value_max" : 4.0, "behavior_available_options" : ["none"]}

var l_movement_type_button_info : Dictionary = {"behavior_name" : "Movement type", "behavior_value" : "move_x", "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : Globals.l_entity_movement_limited}

var l_on_timeout_death_button_info : Dictionary = {"behavior_name" : "Destroy after a delay", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_timeout_death_cooldown_button_info : Dictionary = {"behavior_name" : "Destruction cooldown", "behavior_value" : 1.5, "behavior_value_step" : 0.25, "behavior_value_min" : 0.0, "behavior_value_max" : 12.0, "behavior_available_options" : ["none"]}

var l_on_death_spawn_entity_button_info : Dictionary = {"behavior_name" : "Leave object after death", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_death_spawn_entity_scene_filepath_button_info : Dictionary = {"behavior_name" : "Chosen object", "behavior_value" : "res://Enemies/pursuitron.tscn", "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : Globals.l_entity}
var l_on_death_spawn_entity_quantity_button_info : Dictionary = {"behavior_name" : "Object quantity", "behavior_value" : 1, "behavior_value_step" : 1, "behavior_value_min" : 0, "behavior_value_max" : 15, "behavior_available_options" : ["none"]}
var l_on_death_spawn_entity_add_velocity_button_info : Dictionary = {"behavior_name" : "Object's throw direction", "behavior_value" : Vector2(0, 0), "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_death_spawn_entity_add_velocity_range_button_info : Dictionary = {"behavior_name" : "Object's throw variability range", "behavior_value" : [Vector2(-400, -400), Vector2(400, 400)], "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_death_spawn_entity_pos_offset_button_info : Dictionary = {"behavior_name" : "Object's relative position direction", "behavior_value" : Vector2(0, 0), "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_death_spawn_entity_pos_offset_range_button_info : Dictionary = {"behavior_name" : "Object's relative position variability range", "behavior_value" : [Vector2(-50, -600), Vector2(-400, 600)], "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}

var l_on_hit_spawn_entity_button_info : Dictionary = {"behavior_name" : "Leave object after hit", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_hit_spawn_entity_scene_filepath_button_info : Dictionary = {"behavior_name" : "Chosen object", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : Globals.l_entity}
var l_on_hit_spawn_entity_quantity_button_info : Dictionary = {"behavior_name" : "Object quantity", "behavior_value" : 1, "behavior_value_step" : 1, "behavior_value_min" : 0, "behavior_value_max" : 15, "behavior_available_options" : ["none"]}
var l_on_hit_spawn_entity_add_velocity_button_info : Dictionary = {"behavior_name" : "Object's throw direction", "behavior_value" : Vector2(0, 0), "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_hit_spawn_entity_add_velocity_range_button_info : Dictionary = {"behavior_name" : "Object's throw variability range", "behavior_value" : [Vector2(0, 0), Vector2(0, 0)], "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_hit_spawn_entity_pos_offset_button_info : Dictionary = {"behavior_name" : "Object's relative position direction", "behavior_value" : Vector2(0, 0), "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_on_hit_spawn_entity_pos_offset_range_button_info : Dictionary = {"behavior_name" : "Object's relative position variability range", "behavior_value" : [Vector2(0, 0), Vector2(0, 0)], "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}

var l_on_spawn_copy_direction_x_player_button_info : Dictionary = {"behavior_name" : "Start direction matches that of the player", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_on_spawn_copy_direction_x_active_player_button_info : Dictionary = {"behavior_name" : "But it cannot be inactive", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_copy_direction_x_player_button_info : Dictionary = {"behavior_name" : "Direction matches that of the player, at all times", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_copy_direction_x_active_player_button_info : Dictionary = {"behavior_name" : "But it cannot be inactive", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_direction_x_button_info : Dictionary = {"behavior_name" : "Start direction", "behavior_value" : 1, "behavior_value_step" : 1, "behavior_value_min" : -1, "behavior_value_max" : 1, "behavior_available_options" : ["none"]}

var l_set_player_attack_cooldown_value_button_info : Dictionary = {"behavior_name" : "Spawn cooldown", "behavior_value" : 1.5, "behavior_value_step" : 0.1, "behavior_value_min" : 0.1, "behavior_value_max" : 4.0, "behavior_available_options" : ["none"]}

var l_on_spawn_max_speed_button_info : Dictionary = {"behavior_name" : "Start at maximum speed", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_always_max_speed_button_info : Dictionary = {"behavior_name" : "Always at top speed", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}

var l_breakable_button_info : Dictionary = {"behavior_name" : "Breakable and bouncy", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}

# Unused: - [START]
var l_int_float_button_info : Dictionary = {"behavior_name" : "Movement Speed", "behavior_value" : 400, "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_bool_button_info : Dictionary = {"behavior_name" : "Leave object after hit", "behavior_value" : false, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : [true, false]}
var l_Array_String_button_info : Dictionary = {"behavior_name" : "Chosen object", "behavior_value" : true, "behavior_value_step" : -1, "behavior_value_min" : -1, "behavior_value_max" : -1, "behavior_available_options" : Globals.l_entity}
var l_Vector2_button_info : Dictionary = {"behavior_name" : "Object's relative position direction", "behavior_value" : Vector2(0, 0), "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
var l_Array_Vector2_range_button_info : Dictionary = {"behavior_name" : "Object's relative position variability range", "behavior_value" : [Vector2(-50, -600), Vector2(-400, 600)], "behavior_value_step" : 25, "behavior_value_min" : -1000, "behavior_value_max" : 1000, "behavior_available_options" : ["none"]}
# Unused: - [END]

var choosen_movement_type = "move_x"
var choosen_family = "player"


func _ready():
	Globals.weapon_blocked = true
	
	if Globals.weapon["apply_default"]: # Apply default values if the entity has never been edited.
		for property_name in l_available_property_name:
			Globals.weapon.get_or_add(property_name, get("l_" + property_name + "_button_info")["behavior_value"])
			
			Globals.weapon["apply_default"] = false # From this point, the default property values ("l_property_name_button_info[behavior_value]") will not be applied every time the entity editor spawns.
	
	for property_name in Globals.weapon:
		if property_name == "none" : continue
		
		set(property_name, Globals.weapon[property_name])
	
	for property_name in l_available_property_name:
		
		# Property of float or int value.
		if get("l_" + property_name + "_button_info")["behavior_available_options"] == ["none"]:
			
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_int_float).instantiate()
			
			behavior_button.type = "int_float"
			behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)
		
		# Property of bool value (technically an Array containing "true" and "false").
		elif get("l_" + property_name + "_button_info")["behavior_available_options"] == [true, false]:
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_bool).instantiate()
			
			behavior_button.type = "bool"
			behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)
		
		# Property of Array value.
		else:
			if "range" in property_name:
				# Following code is exactly the same (excluding the type assignment) as the one under the assumption that the property is of numerical type ("int_float").
				var behavior_button = load(Globals.scene_entity_editor_behavior_button_int_float).instantiate()
				
				behavior_button.type = "Array_Vector2_range"
				behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
				behavior_button.property_name = property_name
				behavior_button.property_number = l_available_property_name.find(property_name)
				
				container_behavior_buttons.add_child(behavior_button)
			
			else:
				var behavior_button = load(Globals.scene_entity_editor_behavior_button_Array).instantiate()
				
				behavior_button.type = "Array"
				behavior_button.set("behavior_info", get("l_" + property_name + "_button_info"))
				behavior_button.property_name = property_name
				behavior_button.property_number = l_available_property_name.find(property_name)
				
				container_behavior_buttons.add_child(behavior_button)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("0"):
		Globals.weapon_blocked = false
		queue_free()

# FIX THIS!
func update_entity():
	Globals.weapon = {"apply_default" : true}
	
	for property_name in l_available_property_name:
		Globals.weapon.get_or_add(property_name, get(property_name))


# Start of properties.
@export_group("Main interactions.") # Section start.

@export var collectable = true
@export var hittable = false
@export var collidable = false

@export_group("") # Section end.


#---------------------------------------------------------------------------#


@export_group("Main information.") # Section start.

@export var health_value = 3
@export var damage_value = 1
@export var score_value = 25

@export_enum("stationary", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var movement_type : String = "normal"

@export var speed = 500
@export var jump_velocity = -600
@export var acceleration = 200
@export var friction = 400
@export var fall_speed = 1000

@export var always_max_speed = false
@export var on_spawn_max_speed = false

@export_enum("Player", "enemy", "none", "all") var family : String = "all"
@export var damage_from_entity = false
@export var damage_from_entity_contact = false

@export var set_player_attack_cooldown = false
@export var set_player_attack_cooldown_value = 1.5

@export_group("") # Section end.


#---------------------------------------------------------------------------#


@export_group("Movement specifics.") # Section start.

@export var can_move = false
@export var can_move_x = false
@export var can_move_y = false

@export var ignore_gravity = true
@export var on_death_ignore_gravity_stop = true

@export var speed_multiplier_x = 1.0
@export var speed_multiplier_y = 1.0
@export var acceleration_multiplier_x = 1.0
@export var acceleration_multiplier_y = 1.0
@export var friction_multiplier_x = 1.0
@export var friction_multiplier_y = 1.0
@export var gravity_multiplier_x = 1.0
@export var gravity_multiplier_y = 1.0

@export var on_wall_change_direction_x = true
@export var on_wall_change_speed = false
@export var on_wall_change_speed_multiplier = 0.5
@export var on_wall_change_velocity = true
@export var on_wall_change_velocity_multiplier = Vector2(0.5, 0.5)
@export var on_wall_float = false
@export var on_wall_death = false

@export var on_ledge_turn = false
@export var on_ledge_speed_multiplier = 1.0
@export var on_ledge_death = false

@export var ascending = false

@export var copy_direction_x_player = false
@export var copy_direction_x_active_player = false
@export var on_spawn_copy_direction_x_player = false
@export var on_spawn_copy_direction_x_active_player = true

# Timer-based behavior:
@export var on_timeout_change_direction = false
@export var on_timeout_change_direction_cooldown = 4.0
@export var on_timeout_jump = false
@export var on_timeout_jump_cooldown = 4.0
@export var on_timeout_change_ignore_gravity = false
@export var on_timeout_change_ignore_gravity_cooldown = 2.5
@export var on_timeout_death = false
@export var on_timeout_death_cooldown = 2.5

@export var collidable_cooldown = 0.35

# Behavior triggered on entity death:
@export var on_death_spawn_entity = false
@export_file("*.scene") var on_death_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var on_death_spawn_entity_quantity = 1
@export var on_death_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var on_death_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var on_death_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var on_death_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var on_death_spawn_entity_cooldown = 0.5

@export var on_death_toggle_toggleBlocks = false
@export var on_death_toggle_toggleBlocks_id = 0

@export var on_death_disappearInstantly = false # Spawns some particles and removes the entity right after.


# Behavior triggered on entity hit:
@export var on_hit_spawn_entity = false
@export_file("*.scene") var on_hit_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var on_hit_spawn_entity_quantity = 1
@export var on_hit_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var on_hit_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var on_hit_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var on_hit_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var on_hit_spawn_entity_cooldown = 0.5


# Behavior triggered on entity spotting a "target" entity:
@export var patrolling = false
@export var patrolling_targets = ["Player"] # A valid target is a node with either a matching group name, entity_type or family.
@export var patrolling_vision_size = Vector2(384, 64)
@export var patrolling_vision_pos = Vector2(192, 0)

@export var on_patrolling_spotted_spawn_entity_offset = Vector2(0, 0)
@export_enum("Player", "enemy", "none", "all") var on_patrolling_spotted_spawn_entity_family: String = "enemy"
@export var patrolling_change_direction_cooldown : float = 4.0

@export var on_patrolling_spotted_spawn_entity = false
@export_file("*.scene") var on_patrolling_spotted_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var on_patrolling_spotted_spawn_entity_quantity = 1
@export var on_patrolling_spotted_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var on_patrolling_spotted_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var on_patrolling_spotted_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var on_patrolling_spotted_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var on_patrolling_spotted_spawn_entity_cooldown = 0.5

@export var on_patrolling_spotted_spawn_entity2 = false
@export_file("*.scene") var on_patrolling_spotted_spawn_entity2_scene_filepath = "res://Enemies/togglebot.tscn"
@export var on_patrolling_spotted_spawn_entity2_quantity = 1
@export var on_patrolling_spotted_spawn_entity2_pos_offset : Vector2 = Vector2(0, 0)
@export var on_patrolling_spotted_spawn_entity2_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var on_patrolling_spotted_spawn_entity2_add_velocity : Vector2 = Vector2(0, 0)
@export var on_patrolling_spotted_spawn_entity2_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var on_patrolling_spotted_spawn_entity2_cooldown = 0.5

@export var on_patrolling_spotted_spawn_entity3 = false
@export_file("*.scene") var on_patrolling_spotted_spawn_entity3_scene_filepath = "res://Enemies/togglebot.tscn"
@export var on_patrolling_spotted_spawn_entity3_quantity = 1
@export var on_patrolling_spotted_spawn_entity3_pos_offset : Vector2 = Vector2(0, 0)
@export var on_patrolling_spotted_spawn_entity3_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var on_patrolling_spotted_spawn_entity3_add_velocity : Vector2 = Vector2(0, 0)
@export var on_patrolling_spotted_spawn_entity3_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var on_patrolling_spotted_spawn_entity3_cooldown = 0.5


# Behavior triggered as long as the entity currently satisfies a condition:
@export var when_atStartPosition_x_stop = false
@export var when_atStartPosition_y_stop = false

@export var start_position_leniency_x = 15
@export var start_position_leniency_y = 15

# Behavior triggered on spawn:
@export var on_spawn_offset_position = Vector2(0, 0)
@export var on_spawn_offset_position_random = false
@export var on_spawn_offset_position_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200)) # Maximum variance.

# Behaviour triggered on player touching the entity.
@export var on_touch_modulate = Color(1, 1, 1, 1)

@export_group("") # Section end.


#---------------------------------------------------------------------------#


@export_group("Other properties (behavior).") # Section start.

@export var can_affect_player = false
@export var can_collect = false
@export var look_at_player_x = false
@export var look_at_player_y = false
@export var look_at_player_rotate = false
@export var look_at_player_rotate_offset = 0

@export var on_entityEntered_change_direction_copyEntity = false
@export var on_entityEntered_change_direction_basedOnPosition = false

@export var enteredFromAboveAndNotMoving_enable = true
@export var enteredFromAboveAndNotMoving_velocity = -800


@export var rng_custom = -1 # Set to -1 for random.


@export var collectable_multiple = false
@export var collectable_multiple_health = 4 # Set to "-1" for infinite.

# If an entity is breakable, the player can bounce off of it, and gains greater height if the jump button is pressed during the bounce, making it a "box" in most cases.
@export var breakable = true

@export_enum("Player", "enemy", "none", "all") var breakable_on_death_spawn_entity_family: String = "all"
@export_enum("Player", "enemy", "none", "all") var breakable_on_hit_spawn_entity_family: String = "all"

@export var breakable_on_death_spawn_entity = false
@export_file("*.scene") var breakable_on_death_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var breakable_on_death_spawn_entity_quantity = 1
@export var breakable_on_death_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var breakable_on_death_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var breakable_on_death_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var breakable_on_death_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var breakable_on_death_spawn_entity_cooldown = 0.5

@export var breakable_on_death_player_velocity_y = -200
@export var breakable_on_death_player_velocity_y_jump = -600

@export var breakable_on_hit_spawn_entity = false
@export_file("*.scene") var breakable_on_hit_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var breakable_on_hit_spawn_entity_quantity = 1
@export var breakable_on_hit_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var breakable_on_hit_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var breakable_on_hit_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var breakable_on_hit_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var breakable_on_hit_spawn_entity_cooldown = 0.5

@export var breakable_on_hit_player_velocity_y = -400
@export var breakable_on_hit_player_velocity_y_jump = -600

# Only breakable while these conditions are satisfied.
@export var breakable_requires_velocity_x = true
@export var breakable_requires_velocity_y = true

# Velocity ranges in which a box can be broken. Note: Set to -1 for "never".
# Single range:
@export var breakable_requires_velocity_x_range = Vector2(-1, -1)
@export var breakable_requires_velocity_y_range = Vector2(200, 100000)

# Multiple ranges:
# Example: 1 - [Vector2(-100000, -400) and 2 - [Vector2(400, 100000)] will make the box break only if an entity (or the player) moves into it very fast horizontally.
@export var breakable_requires_velocity_x_range2 = Vector2(-1, -1)
@export var breakable_requires_velocity_y_range2 = Vector2(-1, -1)

# Advanced box is an entity that gained movement after being hit or killed. An example of an advanced box would be the large gem that floats until hit by the player, after which it gains physics-based movement, and can be broken again, opening a level portal.
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var on_hit_gain_movement : String = "none"
@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var on_death_gain_movement : String = "none"
@export var on_death_prevent_death = 0 # How many times an entity death will be prevented.
@export var on_death_prevent_score = 0 # How many times an entity death will not grant any score.

@export var score_value2 = 125
@export var score_value3 = 125
@export var score_value4 = 125
@export var score_value5 = 125

@export var breakable_advanced_on_death_spawn_entity = false
@export_file("*.scene") var breakable_advanced_on_death_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var breakable_advanced_on_death_spawn_entity_quantity = 1
@export var breakable_advanced_on_death_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var breakable_advanced_on_death_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var breakable_advanced_on_death_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var breakable_advanced_on_death_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var breakable_advanced_on_death_spawn_entity_cooldown = 0.5

@export var breakable_advanced_on_death_player_velocity = -400
@export var breakable_advanced_on_death_player_velocity_jump = -600


@export var breakable_advanced_on_hit_spawn_entity = false
@export_file("*.scene") var breakable_advanced__on_hit_spawn_entity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var breakable_advanced_on_hit_spawn_entity_quantity = 1
@export var breakable_advanced_on_hit_spawn_entity_pos_offset : Vector2 = Vector2(0, 0)
@export var breakable_advanced_on_hit_spawn_entity_pos_offset_range : Array = [Vector2(-64, -64), Vector2(64, 64)]
@export var breakable_advanced_on_hit_spawn_entity_add_velocity : Vector2 = Vector2(0, 0)
@export var breakable_advanced_on_hit_spawn_entity_add_velocity_range : Array = [Vector2(-250, -400), Vector2(250, 400)]
@export var breakable_advanced_on_hit_spawn_entity_cooldown = 0.5

@export var breakable_advanced_on_hit_player_velocity = -400
@export var breakable_advanced_on_hit_player_velocity_jump = -600


@export var breakable_advanced_portal_on_death_open = false
@export var breakable_advanced_portal_particle_quantity = 25
@export var breakable_advanced_portal_level_id = "none" # Example: "MAIN_1"
@export var breakable_advanced_portal_checkpoint_offset = Vector2(320, -64)

@export var breakable_advanced_on_touch_modulate = Color(1, 1, 1, 1)

# Major collectibles have a special pickup animation. An example would be the projectile upgrade modules.
@export var majorCollectible_module = false
@export var majorCollectible_key = false

# A temporary powerup will grant an ability for a short time, as well as a score multiplier of x2. Note: Set the ability to "none" for a simple score multiplier powerup.
@export var temporaryPowerup = false
@export_enum("none", "higher_jump", "increased_speed", "teleport_forward_on_airJump") var temporary_powerup = "none"
@export var temporary_powerup_duration = 10

@export var inventory_item = false
@export var inventory_item_scene_filepath = "res://Enemies/togglebot.tscn"
@export var inventory_item_is_hidden = false

@export var is_healthItem = false
@export var rotting = false
@export var fall_when_button_pressed = false

@export var transform_player = false
@export var transform_player_scene_filepath = "res://Enemies/togglebot.tscn"

@export var on_collected_effect_special = false

@export var immortal = false


# General timers. Each one can have an action assigned to it, which will be executed on the matching timer's timeout.
@export var general_timers_enabled = false

@export var t1_cooldown = 3.0
@export var t2_cooldown = 3.0
@export var t3_cooldown = 3.0
@export var t4_cooldown = 3.0
@export var t5_cooldown = 3.0
@export var t6_cooldown = 3.0

@export var t1_on_timeout_randomize_cooldown = false
@export var t2_on_timeout_randomize_cooldown = false
@export var t3_on_timeout_randomize_cooldown = false
@export var t4_on_timeout_randomize_cooldown = false
@export var t5_on_timeout_randomize_cooldown = false
@export var t6_on_timeout_randomize_cooldown = false

@export var t_randomize_cooldown_min = 0.5
@export var t_randomize_cooldown_max = 6

@export var t1_on_spawn_randomize = false
@export var t2_on_spawn_randomize = false
@export var t3_on_spawn_randomize = false
@export var t4_on_spawn_randomize = false
@export var t5_on_spawn_randomize = false
@export var t6_on_spawn_randomize = false

# Actions that can be performed when their respective general timers finish. Note that "t_trigger_[action]" stands for: GENERAL TIMER (t) _ TRIGGER ON TIMEOUT (trigger) _ BEHAVIOR ([action]).
# The values (int) of these properties correspond to a specific general timer, which will look for a behavior matching its ID number on timeout.
# A value of -1 means that this behavior will not match any general timer.
@export var t_trigger_jump = -1
@export var t_trigger_jumpAndMove = -1
@export var t_trigger_change_direction = -1
@export var t_trigger_selfDestruct = -1
@export var t_trigger_selfDestructAndSpawnEntity = -1
@export var t_trigger_sfx = -1
@export var t_trigger_randomize_speedAndJumpVelocity = -1

@export var t_trigger_spawnEntity = -1
@export var t_trigger_spawnEntity_scene_filepath = "res://Enemies/togglebot.tscn"
@export var t_trigger_spawnEntity_quantity = 4
@export var t_trigger_spawnEntity_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity_velocity_random = true
@export var t_trigger_spawnEntity_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

@export var t_trigger_spawnEntity2 = -1
@export var t_trigger_spawnEntity2_scene_filepath = "res://Enemies/togglebot.tscn"
@export var t_trigger_spawnEntity2_quantity = 4
@export var t_trigger_spawnEntity2_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity2_velocity_random = true
@export var t_trigger_spawnEntity2_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

@export var t_trigger_spawnEntity3 = -1
@export var t_trigger_spawnEntity3_scene_filepath = "res://Enemies/togglebot.tscn"
@export var t_trigger_spawnEntity3_quantity = 4
@export var t_trigger_spawnEntity3_velocity = Vector2(200, -400)
@export var t_trigger_spawnEntity3_velocity_random = true
@export var t_trigger_spawnEntity3_velocity_random_variance = Vector2(randi_range(-200, 200), randi_range(-200, 200))

# These properties decide whether or not a specific particle will be spawned:
@export var particle_star = true
@export var particle_orb = true
@export var particle_splash = true
@export var particle_leaf = true
@export var particle_star_fast = true
@export var effect_hit_enemy = true
@export var effect_kill_enemy = true
@export var effect_oneShot_enemy = true

#UNFINISHED
# General particles. These properties control when, where, how many and what kind of particle/effect is supposed to spawn.
# Note that this behavior is very similar to how GENERAL TIMERS work.
@export var p_particle_star = -1
@export var p_particle_orb = -1
@export var p_particle_splash = -1
@export var p_particle_leaf = -1
#UNFINISHED


@export var heal_player = false # Will heal the player even if collected by an entity.
@export var heal_value = 1
@export var heal_entity = false

@export var award_score = true
@export var on_collected_award_score = true
@export var on_hit_award_score = false
@export var on_death_award_score = false

@export var reset_puzzle = false
@export var on_collected_reset_puzzle = false
@export var on_hit_reset_puzzle = false
@export var on_death_reset_puzzle = false

@export var remove_delay = 1.0

@export var on_floor_bounce = false
@export var on_wall_bounce = false

@export var variable_speed = false

@export var anim_alternate_walk = false
@export var anim_alternate_walk_hittable_only_during = false

@export var on_wall_jump_velocity : int = -100

@export_group("") # End of section.


#---------------------------------------------------------------------------#


@export_group("Other properties (visual).") # Section start.

@export_enum("none", "general/loop_up_down", "general/loop_up_down_slight", "general/loop_scale", "gear/rotate") var start_animation = "general/loop_up_down"
@export_enum("none", "general/loop_up_down", "general/rotate_around_y_fade_out", "general/reflect_straight") var on_collected_anim_name : String = "general/fade_out_up"

@export var can_change_sprite_anim : bool = false

@export var disable_sprite_anims = ["none"]
@export var disable_anims = ["none"]

@export var idle_sfx = false
@export var idle_sfx_cooldown = 4.0
@export var idle_sfx_randomize_cooldown = false

@export var on_collected_spawn_star : bool = true
@export var on_collected_spawn_star2 : bool = true
@export var on_collected_spawn_orb_orange : bool = true
@export var on_collected_spawn_orb_blue : bool = true
@export var on_collected_spawn_homing_square_yellow : bool = true

# Sound effects - [START]

# With alternatives for when the effect is inflicted on another entity:
@export_file("*.mp3", "*.wav") var sfx_self_collected_filepath = Globals.d_sfx + "/" + "jewel_collect.wav" # The "self" refers to the sfx playing on ITSELF having died, been collected, killing another entity, etc. So the main sfx properties are the ones with "self" in the middle.
@export_file("*.mp3", "*.wav") var sfx_self_hit_filepath = Globals.d_sfx + "/" + "player_attack.wav"
@export_file("*.mp3", "*.wav") var sfx_self_shot_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
@export_file("*.mp3", "*.wav") var sfx_self_death_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
@export_file("*.mp3", "*.wav") var sfx_self_bounced_filepath = Globals.d_sfx + "/" + "error.wav"
@export_file("*.mp3", "*.wav") var sfx_self_spotted_filepath = Globals.d_sfx + "/" + "error.wav"

# Without the alternatives:
@export_file("*.mp3", "*.wav") var sfx_self_reflected_straight_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
@export_file("*.mp3", "*.wav") var sfx_self_reflected_slope_filepath = Globals.d_sfx + "/" + "error.wav"

# The alternatives:
@export_file("*.mp3", "*.wav") var sfx_collected_filepath = Globals.d_sfx + "/" + "jewel_collect.wav"
@export_file("*.mp3", "*.wav") var sfx_hit_filepath = Globals.d_sfx + "/" + "player_attack.wav"
@export_file("*.mp3", "*.wav") var sfx_shot_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
@export_file("*.mp3", "*.wav") var sfx_death_filepath = Globals.d_sfx + "/" + "laser_shot.wav"
@export_file("*.mp3", "*.wav") var sfx_bounced_filepath = Globals.d_sfx + "/" + "error.wav"
@export_file("*.mp3", "*.wav") var sfx_spotted_filepath = Globals.d_sfx + "/" + "beam_enabled.mp3"

# Sound effects - [END]


@export var on_spawn_effect_grow = true
@export var effect_grow_target_scale = Vector2(1, 1)

@export var on_death_effect_shrink = true
@export var effect_shrink_target_scale = Vector2(1, 1)
@export var effect_shrink_delete : bool = true


@export_group("") # End of section.


@export var entity_name = "none"
@export_enum("collectible", "enemy", "projectile", "box", "block") var entity_type : String = "collectible"
@export var direction_x = 1
@export var direction_y = -1

@export var on_spawn_randomize_everything = false
# End of properties.
