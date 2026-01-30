extends CanvasLayer

# Note: The "lv" stands for "visible layer", and "lh" stands for "hidden layer" (it's reversed on purpose, for naming consistency reasons).
@onready var lv_main : ParallaxLayer = $bg_main_A/layer
@onready var lv_front : ParallaxLayer = $bg_front_A/layer
@onready var lv_front2 : ParallaxLayer = $bg_front2_A/layer
@onready var lv_back : ParallaxLayer = $bg_back_A/layer
@onready var lv_back2 : ParallaxLayer = $bg_back2_A/layer

@onready var lh_main : ParallaxLayer = $bg_main_B/layer
@onready var lh_front : ParallaxLayer = $bg_front_B/layer
@onready var lh_front2 : ParallaxLayer = $bg_front2_B/layer
@onready var lh_back : ParallaxLayer = $bg_back_B/layer
@onready var lh_back2 : ParallaxLayer = $bg_back2_B/layer

@onready var tv_main : TextureRect = lv_main.get_child(0) # The "tv" stands for "visible texture".
@onready var tv_front : TextureRect = lv_front.get_child(0)
@onready var tv_front2 : TextureRect = lv_front2.get_child(0)
@onready var tv_back : TextureRect = lv_back.get_child(0)
@onready var tv_back2 : TextureRect = lv_back2.get_child(0)

@onready var th_main : TextureRect = lh_main.get_child(0)
@onready var th_front : TextureRect = lh_front.get_child(0)
@onready var th_front2 : TextureRect = lh_front2.get_child(0)
@onready var th_back : TextureRect = lh_back.get_child(0)
@onready var th_back2 : TextureRect = lh_back2.get_child(0)

@onready var l_main_edge_top : ParallaxLayer = $bg_main_edge_top/layer
@onready var l_front_edge_top : ParallaxLayer = $bg_front_edge_top/layer
@onready var l_front2_edge_top : ParallaxLayer = $bg_front2_edge_top/layer
@onready var l_back_edge_top : ParallaxLayer = $bg_back_edge_top/layer
@onready var l_back2_edge_top : ParallaxLayer = $bg_back2_edge_top/layer

@onready var t_main_edge_top : TextureRect = l_main_edge_top.get_child(0)
@onready var t_front_edge_top : TextureRect = l_front_edge_top.get_child(0)
@onready var t_front2_edge_top : TextureRect = l_front2_edge_top.get_child(0)
@onready var t_back_edge_top : TextureRect = l_back_edge_top.get_child(0)
@onready var t_back2_edge_top : TextureRect = l_back2_edge_top.get_child(0)

var currently_visible_id = "A"

var list_l_property_name = ["lv_main", "lv_front", "lv_front2", "lv_back", "lv_back2", "lh_main", "lh_front", "lh_front2", "lh_back", "lh_back2"]
var list_l_node_name = ["bg_main_A", "bg_front_A", "bg_front2_A", "bg_back_A", "bg_back2_A", "bg_main_B", "bg_front_B", "bg_front2_B", "bg_back_B", "bg_back2_B"]

var list_lv_property_name = ["lv_main", "lv_front", "lv_front2", "lv_back", "lv_back2"]
var list_lh_property_name = ["lh_main", "lh_front", "lh_front2", "lh_back", "lh_back2"]

var list_l_A_node_name = ["bg_main_A", "bg_front_A", "bg_front2_A", "bg_back_A", "bg_back2_A"]
var list_l_B_node_name = ["bg_main_B", "bg_front_B", "bg_front2_B", "bg_back_B", "bg_back2_B"]


# Opacity transition:
var transition_opacity_active = false

# Contents of a layer are not limited to only a texture, but it is supposed to be the main thing most of the time.
var lv_main_filepath = Globals.bg_main_filepath
var lv_front_filepath = Globals.bg_front_filepath
var lv_front2_filepath = Globals.bg_front2_filepath
var lv_back_filepath = Globals.bg_back_filepath
var lv_back2_filepath = Globals.bg_back2_filepath

var lh_main_filepath = Globals.bg_main_filepath
var lh_front_filepath = Globals.bg_front_filepath
var lh_front2_filepath = Globals.bg_front2_filepath
var lh_back_filepath = Globals.bg_back_filepath
var lh_back2_filepath = Globals.bg_back2_filepath

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


@onready var cooldown_check_fade: Timer = $cooldown_check_fade

var fade_multiplier : float = 0.25

# Not the case for now: # Note: If the filepath value is left as default ("bg_empty.png"), the layer will be deleted on "_ready()".
@onready var bg_main_edge_top_filepath = "res://Assets/Graphics/backgrounds/bg_edge_black.png"
@onready var bg_front_edge_top_filepath = "res://Assets/Graphics/backgrounds/bg_empty.png"
@onready var bg_front2_edge_top_filepath = "res://Assets/Graphics/backgrounds/bg_empty.png"
@onready var bg_back_edge_top_filepath = "res://Assets/Graphics/backgrounds/bg_empty.png"
@onready var bg_back2_edge_top_filepath = "res://Assets/Graphics/backgrounds/bg_empty.png"

@onready var bg_main_repeat_y = true
@onready var bg_front_repeat_y = false
@onready var bg_front2_repeat_y = false
@onready var bg_back_repeat_y = false
@onready var bg_back2_repeat_y = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.trigger_bg_change_entered.connect(on_trigger_bg_change_entered)
	Globals.trigger_bg_move_entered.connect(on_trigger_bg_move_entered)
	Globals.bg_change_finished.connect(on_bg_change_finished)
	
	Globals.debug3.connect(debug_toggle_fully)
	Globals.debug4.connect(debug_highlight_layers)
	
	if Globals.debug_mode : debug_layer_labels()
	
	for l_property_name in list_l_property_name:
		var bg_layer = get(l_property_name)
		bg_layer.visible = true
		Globals.dm(l_property_name)
		Globals.dm(get(l_property_name))
	
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
func _process(delta):
	if bg_fade_active:
		lv_main.modulate.a = move_toward(lv_main.modulate.a, 1.0, delta * fade_multiplier)
		lv_front.modulate.a = move_toward(lv_front.modulate.a, 1.0, delta * fade_multiplier)
		lv_front2.modulate.a = move_toward(lv_front2.modulate.a, 1.0, delta * fade_multiplier)
		lv_back.modulate.a = move_toward(lv_back.modulate.a, 1.0, delta * fade_multiplier)
		lv_back2.modulate.a = move_toward(lv_back2.modulate.a, 1.0, delta * fade_multiplier)
		
		lh_main.modulate.a = move_toward(lh_main.modulate.a, 0.0, delta * fade_multiplier)
		lh_front.modulate.a = move_toward(lh_front.modulate.a, 0.0, delta * fade_multiplier)
		lh_front2.modulate.a = move_toward(lh_front2.modulate.a, 0.0, delta * fade_multiplier)
		lh_back.modulate.a = move_toward(lh_back.modulate.a, 0.0, delta * fade_multiplier)
		lh_back2.modulate.a = move_toward(lh_back2.modulate.a, 0.0, delta * fade_multiplier)
	
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


signal bg_fade_finished

func on_trigger_bg_change_entered():
	bg_fade_active = true
	
	toggle_layer_id()
	bg_update_texture_filepath()
	bg_update_other()
	
	if Globals.debug_mode : debug_layer_labels()


func on_trigger_bg_move_entered():
	pass


func on_bg_change_finished():
	pass


func debug_highlight_layers():
	if not debug_available : return
	debug_available = false
	$cooldown_debug_available.start()
	
	bg_fade_active = false
	
	for layer_name in list_l_node_name:
		var node = get_node(layer_name + "/layer")
		node.modulate = Color(1, 1, 1, 0.0)
	
	for layer_name in list_l_A_node_name:
		Globals.dm("Highlighting a background layer: " + layer_name)
		var node = get_node(layer_name + "/layer")
		node.modulate = Color.GREEN * 4
		await get_tree().create_timer(0.2, true).timeout
		node.modulate = Color(1, 1, 1, 0.0)
	
	for layer_name in list_l_B_node_name:
		Globals.dm("Highlighting a background layer: " + layer_name)
		var node = get_node(layer_name + "/layer")
		node.modulate = Color.RED * 4
		await get_tree().create_timer(0.2, true).timeout
		node.modulate = Color(1, 1, 1, 0.0)
	
	await get_tree().create_timer(1, true).timeout
	
	for layer_name in list_l_node_name:
		var bg_layer = get_node(layer_name + "/layer")
		bg_layer.modulate.a = 1.0
	
	bg_fade_active = true


var fully_active = false

func debug_toggle_fully():
	if not debug_available : return
	debug_available = false
	$cooldown_debug_available.start()
	
	if fully_active:
		Globals.dm("Setting visibility of all Background layers to normal.", "RED")
		
		for layer_name in list_l_node_name:
			await get_tree().create_timer(0.1, true).timeout
			
			var node = get_node(layer_name + "/layer")
			node.z_index -= 100
		
		for layer_name in list_l_node_name:
			await get_tree().create_timer(0.1, true).timeout
			
			var node = get_node(layer_name)
			node.layer -= 100

	else:
		Globals.dm("Setting visibility of all Background layers to full", "GREEN")
		
		for layer_name in list_l_node_name:
			await get_tree().create_timer(0.1, true).timeout
			
			var node = get_node(layer_name + "/layer")
			node.z_index += 100
		
		for layer_name in list_l_node_name:
			await get_tree().create_timer(0.1, true).timeout
			
			var node = get_node(layer_name)
			node.layer += 100
	
	fully_active = Globals.opposite_bool(fully_active)


func toggle_layer_id():
	for layer_name in list_l_B_node_name:
		
		Globals.dm("Currently targeted layer_name: " + layer_name + ".", "YELLOW")
		
		if currently_visible_id == "B":
			Globals.dm("Setting property '%s' to node '%s's layer." % [list_lv_property_name[list_l_B_node_name.find(layer_name)], get_node(layer_name + "/layer").get_parent().name], 2)
			set(list_lv_property_name[list_l_B_node_name.find(layer_name)], get_node(layer_name + "/layer"))
		elif currently_visible_id == "A":
			Globals.dm("Setting property '%s' to node '%s's layer." % [list_lh_property_name[list_l_B_node_name.find(layer_name)], get_node(layer_name + "/layer").get_parent().name], 1)
			set(list_lh_property_name[list_l_B_node_name.find(layer_name)], get_node(layer_name + "/layer"))
		
		
	for layer_name in list_l_A_node_name:
		
		Globals.dm("Currently targeted layer_name: " + layer_name + ".", "ORANGE")
		
		if currently_visible_id == "A":
			Globals.dm("Setting property '%s' to node '%s's layer." % [list_lv_property_name[list_l_A_node_name.find(layer_name)], get_node(layer_name + "/layer").get_parent().name], 4)
			set(list_lv_property_name[list_l_A_node_name.find(layer_name)], get_node(layer_name + "/layer"))
		elif currently_visible_id == "B":
			Globals.dm("Setting property '%s' to node '%s's layer." % [list_lh_property_name[list_l_A_node_name.find(layer_name)], get_node(layer_name + "/layer").get_parent().name], 3)
			set(list_lh_property_name[list_l_A_node_name.find(layer_name)], get_node(layer_name + "/layer"))
	
	
	tv_main = lv_main.get_child(0) # The "tv" stands for "visible texture".
	tv_front = lv_front.get_child(0)
	tv_front2 = lv_front2.get_child(0)
	tv_back = lv_back.get_child(0)
	tv_back2 = lv_back2.get_child(0)
	
	th_main = lh_main.get_child(0)
	th_front = lh_front.get_child(0)
	th_front2 = lh_front2.get_child(0)
	th_back = lh_back.get_child(0)
	th_back2 = lh_back2.get_child(0)
	
	
	if currently_visible_id == "A" : currently_visible_id = "B"
	elif currently_visible_id == "B" : currently_visible_id = "A"


func bg_update_texture_filepath():
	Globals.dm("Updating textures for all Background layers.", "LIME_GREEN")
	Globals.dm("Main layer's filepath: " + load(Globals.bg_main_filepath).get_path())
	
	lv_main_filepath = Globals.bg_main_filepath
	lv_front_filepath = Globals.bg_front_filepath
	lv_front2_filepath = Globals.bg_front2_filepath
	lv_back_filepath = Globals.bg_back_filepath
	lv_back2_filepath = Globals.bg_back2_filepath
	
	tv_main.texture = load(lv_main_filepath)
	tv_front.texture = load(lv_front_filepath)
	tv_front2.texture = load(lv_front2_filepath)
	tv_back.texture = load(lv_back_filepath)
	tv_back2.texture = load(lv_back2_filepath)


var debug_available = true

func _on_cooldown_debug_available_timeout() -> void:
	debug_available = true


func _on_cooldown_check_fade_timeout() -> void:
	return
	Globals.dm(lv_main.modulate.a, "GREEN")
	Globals.dm(lv_main, "GREEN")
	if lv_main.modulate.a == 0.0 or lv_main.modulate.a == 1.0:
		bg_fade_finished.emit()
		Globals.dm("bg_fade_finished", "ORANGE")
	
	Globals.dm(lh_main.modulate.a, "RED")
	Globals.dm(lh_main, "RED")
	if lh_main.modulate.a == 0.0 or lh_main.modulate.a == 1.0:
		bg_fade_finished.emit()
		Globals.dm("bg_fade_finished", "ORANGE")


func debug_layer_labels():
	await get_tree().create_timer(0.5, true).timeout
	for property_name in list_l_property_name:
		var node = get(property_name)
		
		for x in node.get_children():
			if x.is_in_group("debug_label"):
				x.queue_free()
		
		var label = Label.new()
		label.text = str(node.get_parent().name + " - " + property_name)
		label.add_to_group("debug_label")
		node.add_child(label)


func bg_update_other():
	bg_main_edge_top_filepath = Globals.bg_main_edge_top_filepath
	bg_front_edge_top_filepath = Globals.bg_front_edge_top_filepath
	bg_front2_edge_top_filepath = Globals.bg_front2_edge_top_filepath
	bg_back_edge_top_filepath = Globals.bg_back_edge_top_filepath
	bg_back2_edge_top_filepath = Globals.bg_back2_edge_top_filepath
	
	t_main_edge_top.texture = load(bg_main_edge_top_filepath)
	t_front_edge_top.texture = load(bg_front_edge_top_filepath)
	t_front2_edge_top.texture = load(bg_front2_edge_top_filepath)
	t_back_edge_top.texture = load(bg_back_edge_top_filepath)
	t_back2_edge_top.texture = load(bg_back2_edge_top_filepath)
	
	
	bg_main_repeat_y = Globals.bg_main_repeat_y
	bg_front_repeat_y = Globals.bg_front_repeat_y
	bg_front2_repeat_y = Globals.bg_front2_repeat_y
	bg_back_repeat_y = Globals.bg_back_repeat_y
	bg_back2_repeat_y = Globals.bg_back2_repeat_y
	
	Globals.dm(str(bg_main_repeat_y,bg_front_repeat_y,bg_front2_repeat_y), 99)
	if bg_main_repeat_y : lv_main.motion_mirroring.y = 2160
	else : lv_main.motion_mirroring.y = 0
	if bg_front_repeat_y : lv_front.motion_mirroring.y = 2160
	else : lv_front.motion_mirroring.y = 0
	if bg_front2_repeat_y : lv_front2.motion_mirroring.y = 2160 ; Globals.dm(str(bg_front2_repeat_y, lv_front2.motion_mirroring.y))
	else : lv_front2.motion_mirroring.y = 0 ; Globals.dm("FALSE")
	if bg_back_repeat_y : lv_back.motion_mirroring.y = 2160
	else : lv_back.motion_mirroring.y = 0
	if bg_back2_repeat_y : lv_back2.motion_mirroring.y = 2160
	else : lv_back2.motion_mirroring.y = 0
