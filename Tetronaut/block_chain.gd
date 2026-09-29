extends Control

@onready var text_manager: Control = $text_manager

@export var segment_quantity : int = 1

var block_size : Vector2 = Vector2(64, 64)
var size_tiles : Vector2 = Vector2(0, 0)

var next_add_pos : Vector2 = Vector2(0, 0)

var next_direction : Vector2 = Vector2(0, 0)
var previous_direction : Vector2 = Vector2(0, 0)
var block_previous_pos : Vector2 = Vector2(0, 0)

var chain_color : Color = Color(-1, -1, -1, -1)
var block_on_collected_anim_name : String = "none"
var block_on_collected_anim_speed : float = -1.0

var block_score_value : int = -1
var chain_score_value : int = -1


var solved : bool = false

var current_blocks : int = 0

func _ready() -> void:
	chain_score_value = randi_range(25, 250)
	
	chain_color = Globals.l_color_all.pick_random()
	block_on_collected_anim_name = Globals.l_animation_name_general_all.pick_random()
	block_on_collected_anim_speed = randf_range(0.5, 1.0)
	
	segment_quantity = randi_range(1, 12)
	
	for block in segment_quantity:
		if not block : continue
		
		previous_direction = next_direction
		next_direction = Vector2(0, 0)
		
		if block == 1 : next_direction = Vector2(0, 0)
		else:
			next_direction.x = randi_range(0, 1)
			if next_direction.x : next_direction.y = 0
			else : next_direction.y = 1
		
		var spawned_segments : Array = await Globals.spawn_scenes(self, load("res://Tetronaut/block_general.tscn"), 1, block_previous_pos + next_direction * block_size, -1, Color(0, 0, 0, 0), Vector2(0, 0), block * 4)
		var segment : Node = spawned_segments[0]
		
		segment.segment_number = block
		segment.block_color = chain_color # This is not a mistake.
		segment.block_on_collected_anim_name = block_on_collected_anim_name
		segment.block_on_collected_anim_speed = block_on_collected_anim_speed
		segment.block_score_value = block_score_value
		
		size_tiles = next_direction
		block_previous_pos = block_previous_pos + next_direction * block_size

func _physics_process(delta: float) -> void:
	modulate.a = move_toward(modulate.a, 1.0, delta)
	scale = scale.move_toward(Vector2(1, 1), delta)
	
	if mouse_inside and Input.is_action_pressed("LMB") or mouse_held and Input.is_action_pressed("LMB"):
		if not mouse_held:
			mouse_start_pos = get_global_mouse_position()
			chain_start_pos = position
			#Globals.spawn_message_object("new mouse start pos", Globals.main_scene, get_global_mouse_position(), true, Vector2(1, 1))
		
		if not is_mouse_focused() : mouse_held = true
		
		mouse_target_pos = get_global_mouse_position() - mouse_start_pos + chain_start_pos
		position = lerp(position, mouse_target_pos, delta * 10)
		modulate.a = 0.75
	
	elif mouse_held and not Input.is_action_pressed("LMB"):
		if mouse_held : scale *= 1.05 ; modulate = Color.WHITE * 1.5
		mouse_held = false
		place_if_requested_pos_valid()


var mouse_inside : bool = false
var mouse_held : bool = false
var mouse_start_pos : Vector2 = Vector2(0, 0)
var mouse_target_pos : Vector2 = Vector2(0, 0)
var chain_start_pos : Vector2 = Vector2(0, 0)

func _on_mouse_entered() -> void:
	mouse_inside = true

func _on_mouse_exited() -> void:
	mouse_inside = false

#func _input(event: InputEvent) -> void:
	#if mouse_inside and Input.is_action_pressed("LMB"):
	
		#modulate.a = 0.1
		#solved = true
		#mouse_filter = 2
		#for block in get_children():
			#block.solved = true
			#block.mouse_filter = 0
		
		#Globals.spawn_message_object("block chain solved", Globals.main_scene, get_global_mouse_position(), true, Vector2(1, 1))

func is_mouse_focused():
	var result : bool = false
	
	for block_chain in get_tree().get_nodes_in_group("tn_block_chain"):
		if block_chain.mouse_held : result = true
	
	return result

func place_if_requested_pos_valid():
	var requested_position : Vector2 = position
	if is_requested_pos_valid():
		for block in get_children():
			if not "text_full" in block : block.on_chain_placed()
			return
	
	for x in range(32):
		if int(position.x) % 64 == 0 : continue
		position.x = requested_position.x - x
		if int(position.x) % 64 == 0 : continue
		position.x = requested_position.x + x
	
	for y in range(32):
		if int(position.y) % 64 == 0 : continue
		position.y = requested_position.y - y
		if int(position.y) % 64 == 0 : continue
		position.y = requested_position.y + y
	
	await get_tree().create_timer(0.05, true).timeout
	
	for block in get_children():
		if not "text_full" in block : block.on_chain_placed()
	
	await get_tree().create_timer(2.5, true).timeout
	
	delete_if_collected()

func is_requested_pos_valid():
	if int(position.x) % 64 == 0 and int(position.y) % 64 == 0 : return true
	else : return false

func delete_if_collected():
	current_blocks = 0
	for node in get_children():
		if node.is_in_group("tn_block"):
			if not node.collected:
				current_blocks += 1
	
	if current_blocks <= 0:
		var experience_value : int = 1000
		Overlay.hud_player_experience.experience_increase(experience_value + (randi_range(0, Globals.player_level * Globals.player_level)) + randi_range(-experience_value * 0.1, experience_value * 0.1))
		queue_free()
