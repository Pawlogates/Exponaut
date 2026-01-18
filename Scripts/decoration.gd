extends Node2D

@export var type = "gear" # The DECORATION node's name should always match this value, because of how animation players are dynamically added to the decoration core (the one that has this script attached to it).

@onready var decoration : Node2D = get_child(3)

@onready var animation_general : AnimationPlayer
@onready var animation_gear : AnimationPlayer

@onready var glow_light: PointLight2D = $glow_light

@export var anim_name : String = "loop_right_left"
@export var anim_speed : float = 1.0
@export var anim_reverse : bool = false

@export var anim_name2 : String = "rotate"
@export var anim_speed2 : float = 1.0
@export var anim_reverse2 : bool = false

# Randomization:
@export var randomize_multiplier : float = 1.0
@export var randomize_multiplier2 : float = 1.0

@export var randomize_anim_name : bool = false
@export var randomize_anim_speed : bool = false
@export var randomize_anim_reverse : bool = false

@export var randomize_anim_name2 : bool = false
@export var randomize_anim_speed2 : bool = false
@export var randomize_anim_reverse2 : bool = false

@export var randomize_modulate_dark : bool = false

var is_near_edge = 0 # Directional ("-1" = left, "1" = right).
var near_edge_offset = 0


func _ready() -> void:
	Globals.message_debug("Connecting debug signal 3 to a Decoration Core, with the target function being 'debug_show_anim_names'.")
	Globals.debug3.connect(debug_show_anim_names)
	
	if decoration == null : return
	
	reassign_general()
	
	if not animation_general.is_playing() and not animation_gear.is_playing() : play_anim(false)
	
	glow_light.offset += Vector2(randi_range(-50, 50), randi_range(-50, 50))


func play_anim(randomize_everything : bool = true):
	reassign_general()
	
	if randomize_everything:
		set_randomize_everything()
	
	randomize_anim() # Won't actually do anything if all properties are set to default values.
	
	animation_general.speed_scale = anim_speed
	animation_gear.speed_scale = anim_speed2
	
	if anim_name != "none":
		if anim_reverse:
			animation_general.play_backwards(anim_name)
		else:
			animation_general.play(anim_name)
	
	if anim_name2 != "none":
		if anim_reverse2:
			animation_gear.play_backwards(anim_name2)
		else:
			animation_gear.play(anim_name2)
	
	if is_near_edge:
		if "right_left" in anim_name:
			
			var offset_multiplier = 1
			
			if "x2" in anim_name : offset_multiplier = 2
			elif "x4" in anim_name : offset_multiplier = 4
			elif "x8" in anim_name : offset_multiplier = 8
			
			near_edge_offset = 64 * (offset_multiplier / abs(is_near_edge)) * scale.x
			
			if is_near_edge < 0:
				position.x += near_edge_offset
				Globals.message_debug("Animation name suggests that the node may not appear to be inside its parent node at all times. It has been moved right by %s pixels." % str(near_edge_offset), 2)
			elif is_near_edge > 0:
				position.x -= near_edge_offset
				Globals.message_debug("Animation name suggests that the node may not appear to be inside its parent node at all times. It has been moved left by %s pixels." % str(near_edge_offset), 3)


func randomize_anim():
	if randomize_anim_name : anim_name = Globals.l_animation_name_general_limited.pick_random()
	if randomize_anim_speed : anim_speed = randf_range(0.05 * randomize_multiplier, 2 * randomize_multiplier)
	if randomize_anim_reverse : anim_reverse = Globals.random_bool(1, 1)
	
	if randomize_anim_name2 : anim_name2 = Globals.l_animation_name_gear.pick_random()
	if randomize_anim_speed2 : anim_speed2 = randf_range(0.05 * randomize_multiplier2, 2 * randomize_multiplier2)
	if randomize_anim_reverse2 : anim_reverse2 = Globals.random_bool(1, 1)
	
	if randomize_modulate_dark:
		if Globals.random_bool(3, 1):
			modulate = Color(0, 0, 0, 1)
		else:
			if Globals.random_bool(3, 1):
				var rolled_value = randf_range(0, 1)
				modulate = Color(rolled_value, rolled_value, rolled_value, 1)

func set_randomize_everything():
	randomize_anim_name = true
	randomize_anim_reverse = true
	randomize_anim_speed = true
	randomize_anim_name2 = true
	randomize_anim_reverse2 = true
	randomize_anim_speed2 = true
	randomize_modulate_dark = true


func reassign_general():
	for animation_type in Globals.l_animation_type:
		
		var node_name = "animation_" + animation_type
		
		if not has_node(node_name):
			Globals.message_debug("Adding an animation player to Decoration Core, node name: " + str(node_name))
			var node = Globals.get("scene_" + node_name).instantiate()
			decoration.add_child(node)
			
			set(node_name, node)


func debug_show_anim_names():
	$debug/debug_anim_name.text = anim_name
	$debug/debug_anim_name2.text = anim_name2
	$debug/debug_is_near_edge.text = str(is_near_edge)
	
	if is_near_edge > 0 : $debug/debug_is_near_offset_x.text = str(-near_edge_offset)
	elif is_near_edge < 0 : $debug/debug_is_near_offset_x.text = str(near_edge_offset)
	
	$debug.visible = Globals.opposite_bool($debug.visible)
	$debug_real_pos.visible = Globals.opposite_bool($debug_real_pos.visible)
