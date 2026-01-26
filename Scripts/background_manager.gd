extends CanvasLayer

# Note: The "lv" stands for "visible layer", and "lh" stands for "hidden layer" (it's reversed on purpose, for naming consistency reasons).
@onready var lv_main : ParallaxLayer = $bg_main_A/layer
@onready var lv_front : ParallaxLayer = $bg_front_A/layer
@onready var lv_front2 : ParallaxLayer = $bg_front2_A/layer
@onready var lv_hidden : ParallaxLayer = $bg_hidden_A/layer
@onready var lv_hidden2 : ParallaxLayer = $bg_hidden2_A/layer

@onready var lh_main : ParallaxLayer = $bg_front_B/layer
@onready var lh_front : ParallaxLayer = $bg_front_B/layer
@onready var lh_front2 : ParallaxLayer = $bg_front2_B/layer
@onready var lh_hidden : ParallaxLayer = $bg_hidden_B/layer
@onready var lh_hidden2 : ParallaxLayer = $bg_hidden2_B/layer

var currently_visible_id = "A"

var l_layer_property_name = ["lv_main", "lv_front", "lv_front2", "lv_back", "lv_back2", "lh_main", "lh_front", "lh_front2", "lh_back", "lh_back2"]
var l_layer_node_name = ["bg_main_A", "bg_front_A", "bg_front2_A", "bg_back_A", "bg_back2_A", "bg_main_B", "bg_front_B", "bg_front2_B", "bg_back_B", "bg_back2_B"]


# Opacity transition:
var transition_opacity_active = false

# Contents of a layer are not limited to only a texture, but it is supposed to be the main thing most of the time.
var lv_main_filepath = Globals.bg_main_visible_filepath
var lv_front_filepath = Globals.bg_main_visible_filepath
var lv_front2_filepath = Globals.bg_main_visible_filepath
var lv_hidden_filepath = Globals.bg_main_visible_filepath
var lv_hidden2_filepath = Globals.bg_main_visible_filepath

var hl_main_filepath = Globals.bg_main_visible_filepath
var hl_front_filepath = Globals.bg_main_visible_filepath
var hl_front2_filepath = Globals.bg_main_visible_filepath
var hl_hidden_filepath = Globals.bg_main_visible_filepath
var hl_hidden2_filepath = Globals.bg_main_visible_filepath

# The "l" stands for "layer", and refers to both visible and invisible layers.
var l_main_offset_target = Vector2(0, 0)
var l_front_offset_target = Vector2(0, 0)
var l_front2_offset_target = Vector2(0, 0)
var l_back_offset_target = Vector2(0, 0)
var l_back2_target = Vector2(0, 0)

# Color transition:
var transition_color_active = false

var l_main_modulate = Color(1, 1, 1, 1)
var l_front_modulate = Color(1, 1, 1, 1)
var l_front2_modulate = Color(1, 1, 1, 1)
var l_back_modulate = Color(1, 1, 1, 1)
var l_back2_modulate = Color(1, 1, 1, 1)


#signal trigger_bg_change_entered
#signal trigger_bg_move_entered
#signal bg_change_finished


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.trigger_bg_change_entered.connect(on_trigger_bg_change_entered)
	Globals.trigger_bg_move_entered.connect(on_trigger_bg_move_entered)
	Globals.bg_change_finished.connect(on_bg_change_finished)
	
	await get_tree().create_timer(0.5, true).timeout
	
	for layer_name in l_layer_node_name:
		await get_tree().create_timer(0.1, true).timeout
		if layer_name.ends_with("A") or layer_name.ends_with("B"):
			var node = get_node(layer_name + "/layer")
			node.z_index += 100
	
	for layer_name in l_layer_node_name:
		await get_tree().create_timer(0.1, true).timeout
		if layer_name.ends_with("A") or layer_name.ends_with("B"):
			var node = get_node(layer_name)
			node.layer += 100
	
	#for layer_name in l_layer_node_name:
		#if layer_name.ends_with("B"):
			#Globals.dm("Hiding a background layer: " + layer_name)
			#var node = get_node(layer_name + "/layer")
			#node.modulate.a = 0
			#await get_tree().create_timer(0.5, true).timeout
		#
		#if layer_name.ends_with("A"):
			#Globals.dm("Hiding a background layer: " + layer_name)
			#var node = get_node(layer_name + "/layer")
			#node.modulate.a = 0
			#await get_tree().create_timer(0.5, true).timeout
	
	await get_tree().create_timer(1, true).timeout
	debug_highlight_layers()
	
	#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.r = main_r
	#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.g = main_g
	#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.b = main_b
	#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.a = main_a
	#
	#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.r = a_r
	#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.g = a_g
	#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.b = a_b
	#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.a = a_a
	#
	#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.r = b_r
	#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.g = b_g
	#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.b = b_b
	#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.a = b_a

@onready var animation_fade: AnimationPlayer = %animation_fade
var bg_fade_active : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#if changing_color and %bg_transition.current_animation == "" and %bg_a_transition.current_animation == "" and %bg_b_transition.current_animation == "":
		#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.r = main_r
		#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.g = main_g
		#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.b = main_b
		#$CanvasLayer/bg_main/bg_main/TextureRect.modulate.a = main_a
		#
		#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.r = a_r
		#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.g = a_g
		#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.b = a_b
		#$CanvasLayer/bg_a/bg_a/TextureRect.modulate.a = a_a
		#
		#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.r = b_r
		#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.g = b_g
		#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.b = b_b
		#$CanvasLayer/bg_b/bg_b/TextureRect.modulate.a = b_a


func on_trigger_bg_change_entered():
	if currently_visible_id == "A" : currently_visible_id = "B"
	elif currently_visible_id == "B" : currently_visible_id = "A"
	
	for layer_name in l_layer_node_name:
		set(l_layer_property_name[l_layer_node_name.find(layer_name)], get_node(layer_name))
	
	for layer_name in l_layer_node_name:
		if layer_name.ends_with("A"):
			var layer = get(layer_name)
			set(l_layer_property_name[l_layer_node_name.find(layer_name)], get_node(layer_name.replace("A", "B") + "/layer"))
		
		elif layer_name.ends_with("B"):
			var layer = get(layer_name)
			set(l_layer_property_name[l_layer_node_name.find(layer_name)], get_node(layer_name.replace("B", "A") + "/layer"))


func on_trigger_bg_move_entered():
	pass


func on_bg_change_finished():
	pass


func debug_highlight_layers():
	for layer_name in l_layer_node_name:
		if layer_name.ends_with("A") or layer_name.ends_with("B"):
			var node = get_node(layer_name + "/layer")
			node.modulate = Color(1, 1, 1, 0.5)
	
	for layer_name in l_layer_node_name:
		if layer_name.ends_with("A"):
			Globals.dm("Highlighting a background layer: " + layer_name)
			var node = get_node(layer_name + "/layer")
			node.modulate = Color.RED * 4
			await get_tree().create_timer(0.2, true).timeout
			node.modulate = Color(1, 1, 1, 0.5)
		
		elif layer_name.ends_with("B"):
			Globals.dm("Highlighting a background layer: " + layer_name)
			var node = get_node(layer_name + "/layer")
			node.modulate = Color.GREEN * 4
			await get_tree().create_timer(0.2, true).timeout
			node.modulate = Color(1, 1, 1, 0.5)
	
	await get_tree().create_timer(1, true).timeout
	
	for layer_name in l_layer_node_name:
		
		var node = get_node(layer_name + "/layer")
		
		if layer_name.ends_with(currently_visible_id):
			node.modulate = Color(1, 1, 1, 1)
		
		else:
			node.modulate = Color(0, 0, 0, 0)
	
	await get_tree().create_timer(1, true).timeout
	
	for layer_name in l_layer_node_name:
		await get_tree().create_timer(0.1, true).timeout
		if layer_name.ends_with("A") or layer_name.ends_with("B"):
			var node = get_node(layer_name + "/layer")
			node.z_index -= 100
	
	for layer_name in l_layer_node_name:
		await get_tree().create_timer(0.1, true).timeout
		if layer_name.ends_with("A") or layer_name.ends_with("B"):
			var node = get_node(layer_name)
			node.layer -= 100
