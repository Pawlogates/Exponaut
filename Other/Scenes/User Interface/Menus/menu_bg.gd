extends Control

@onready var fill: ColorRect = $fill
@onready var outline_left: ColorRect = $outline_left
@onready var outline_right: ColorRect = $outline_right
@onready var outline_bottom: ColorRect = $outline_bottom
@onready var outline_top: ColorRect = $outline_top


@export var width : int = -1
@export var height : int = -1

@export var outline_top_width : float = 8
@export var outline_bottom_width : float = 8
@export var outline_left_width : float = 8
@export var outline_right_width : float = 8

var edge_top_left : Node
var edge_top_right : Node
var edge_bottom_left : Node
var edge_bottom_right : Node

var outline_top_start_size : Vector2
var outline_bottom_start_size : Vector2
var outline_left_start_size : Vector2
var outline_right_start_size : Vector2

var outline_top_start_pos : Vector2
var outline_bottom_start_pos : Vector2
var outline_left_start_pos : Vector2
var outline_right_start_pos : Vector2

var edge_top_left_start_pos : Vector2
var edge_top_right_start_pos : Vector2
var edge_bottom_left_start_pos : Vector2
var edge_bottom_right_start_pos : Vector2

var outline_top_ready_size : Vector2
var outline_bottom_ready_size : Vector2
var outline_left_ready_size : Vector2
var outline_right_ready_size : Vector2

var outline_top_ready_pos : Vector2
var outline_bottom_ready_pos : Vector2
var outline_left_ready_pos : Vector2
var outline_right_ready_pos : Vector2

var edge_top_left_ready_pos : Vector2
var edge_top_right_ready_pos : Vector2
var edge_bottom_left_ready_pos : Vector2
var edge_bottom_right_ready_pos : Vector2

@export var edge_top_left_filepath : String = "res://Other/Scenes/User Interface/Menus/menu_bg_edge.tscn"
@export var edge_top_right_filepath : String = "res://Other/Scenes/User Interface/Menus/menu_bg_edge.tscn"
@export var edge_bottom_left_filepath : String = "res://Other/Scenes/User Interface/Menus/menu_bg_edge.tscn"
@export var edge_bottom_right_filepath : String = "res://Other/Scenes/User Interface/Menus/menu_bg_edge.tscn"

@export var randomize_basic : bool = true
@export var randomize_advanced : bool = false

@export var diffuse : bool = true

var is_ready : bool = false

@export var outline_top_overflow : bool = false
@export var outline_bottom_overflow : bool = false
@export var outline_left_overflow : bool = false
@export var outline_right_overflow : bool = false

@export var randomize_outline_overflow : bool = true

@export var margin : Vector2 = Vector2(0, 0)


func _ready() -> void:
	await get_tree().create_timer(0.05, true).timeout
	
	if randomize_speed_multiplier:
		speed_multiplier1 = randi_range(0.05, 4)
		speed_multiplier2 = randi_range(0.05, 4)
		speed_multiplier3 = randi_range(0.05, 4)
		speed_multiplier4 = randi_range(0.05, 4)
	
	if randomize_advanced:
		width = randi_range(50, 2000)
		height = randi_range(50, 1000)
	
	if width != -1 : outline_top.size.x = width
	if width != -1 : outline_bottom.size.x = width
	if height != -1 : outline_left.size.y = height
	if height != -1 : outline_right.size.y = height
	
	outline_top.size += Vector2(margin.x / 2, 0)
	outline_bottom.size += Vector2(margin.x / 2, 0)
	outline_left.size += Vector2(0, margin.y / 2)
	outline_right.size += Vector2(0, margin.y / 2)
	
	# Apply outline width:
	outline_top.size.y = outline_top_width
	outline_bottom.size.y = outline_bottom_width
	outline_left.size.x = outline_left_width
	outline_right.size.x = outline_right_width
	
	edge_top_left = await Globals.spawn_scenes(outline_top, edge_top_left_filepath, 1, Vector2(0, 0), -1)
	edge_top_right = await Globals.spawn_scenes(outline_top, edge_top_left_filepath, 1, Vector2(0, 0), -1)
	edge_bottom_left = await Globals.spawn_scenes(outline_bottom, edge_top_left_filepath, 1, Vector2(0, 0), -1)
	edge_bottom_right = await Globals.spawn_scenes(outline_bottom, edge_top_left_filepath, 1, Vector2(0, 0), -1)
	
	if outline_top_width != 8:
		var copy : Node
		
		for x in 4:
			copy = edge_top_left.duplicate()
			copy.rotation_degrees = 90 * x
			if copy.rotation_degrees == 0 : copy.position += Vector2(-32, 32) * scale
			elif copy.rotation_degrees == 90 : copy.position += Vector2(0, 0) * scale
			elif copy.rotation_degrees == 180 : copy.position += Vector2(32, 32) * scale
			else : copy.position += Vector2(0, 64) * scale
			outline_top.add_child(copy)
		
		for x in 4:
			copy = edge_top_right.duplicate()
			copy.rotation_degrees = 90 * x
			if copy.rotation_degrees == 0 : copy.position += Vector2(-32, 32) * scale
			elif copy.rotation_degrees == 90 : copy.position += Vector2(0, 0) * scale
			elif copy.rotation_degrees == 180 : copy.position += Vector2(32, 32) * scale
			else : copy.position += Vector2(0, 64) * scale
			copy.position.y -= 32 * scale.y
			copy.position.x -= 24 * scale.x
			outline_right.add_child(copy)
		
		for x in 4:
			copy = edge_bottom_left.duplicate()
			copy.rotation_degrees = 90 * x
			if copy.rotation_degrees == 0 : copy.position += Vector2(-32, 32) * scale
			elif copy.rotation_degrees == 90 : copy.position += Vector2(0, 0) * scale
			elif copy.rotation_degrees == 180 : copy.position += Vector2(32, 32) * scale
			else : copy.position += Vector2(0, 64) * scale
			copy.position.y -= 56 * scale.y
			copy.position.x -= 0 * scale.x
			outline_bottom.add_child(copy)
		
		for x in 4:
			copy = edge_bottom_right.duplicate()
			copy.rotation_degrees = 90 * x
			if copy.rotation_degrees == 0 : copy.position += Vector2(-32, 32) * scale
			elif copy.rotation_degrees == 90 : copy.position += Vector2(0, 0) * scale
			elif copy.rotation_degrees == 180 : copy.position += Vector2(32, 32) * scale
			else : copy.position += Vector2(0, 64) * scale
			copy.position.y -= 12 * scale.y
			copy.position.x -= 24 * scale.x
			outline_right.add_child(copy)
		
		#edge_top_left.visible = false
		#edge_top_right.visible = false
		#edge_bottom_left.visible = false
		#edge_bottom_right.visible = false
	
	#edge_top_left.scale *= outline_top_width / 8
	#edge_top_right.scale *= outline_top_width / 8
	#edge_bottom_left.scale *= outline_bottom_width / 8
	#edge_bottom_right.scale *= outline_bottom_width / 8
	
	outline_right.position.x = outline_top.size.x
	outline_bottom.position.y = outline_left.size.y
	
	outline_top.position -= margin / 4
	outline_bottom.position -= margin / 4
	outline_left.position -= margin / 4
	outline_right.position -= margin / 4
	
	edge_top_left_start_pos = edge_top_left.position
	edge_top_right_start_pos = edge_top_right.position
	edge_bottom_left_start_pos = edge_bottom_left.position
	edge_bottom_right_start_pos = edge_bottom_right.position
	
	outline_top_start_size = outline_top.size
	outline_bottom_start_size = outline_bottom.size
	outline_left_start_size = outline_left.size
	outline_right_start_size = outline_right.size
	
	outline_top_start_pos = outline_top.position
	outline_bottom_start_pos = outline_bottom.position
	outline_left_start_pos = outline_left.position
	outline_right_start_pos = outline_right.position
	
	await get_tree().create_timer(0.05, true).timeout
	
	deco_create()
	
	edge_top_left_ready_pos = edge_top_left.position
	edge_top_right_ready_pos = edge_top_right.position
	edge_bottom_left_ready_pos = edge_bottom_left.position
	edge_bottom_right_ready_pos = edge_bottom_right.position
	
	outline_top_ready_size = outline_top.size
	outline_bottom_ready_size = outline_bottom.size
	outline_left_ready_size = outline_left.size
	outline_right_ready_size = outline_right.size
	
	outline_top_ready_pos = outline_top.position
	outline_bottom_ready_pos = outline_bottom.position
	outline_left_ready_pos = outline_left.position
	outline_right_ready_pos = outline_right.position
	
	width = outline_top.size.x
	height = outline_left.size.y
	
	if diffuse:
		outline_top.size.x -= randi_range(-width / 10, width)
		outline_bottom.size.x -= randi_range(-width / 10, width)
		outline_left.size.y -= randi_range(-height / 10, height)
		outline_right.size.y -= randi_range(-height / 10, height)
		
		deco_diffuse_velocity1_target = randi_range(-50, 200)
		deco_diffuse_velocity2_target = randi_range(-50, 200)
		deco_diffuse_velocity3_target = randi_range(-50, 200)
		deco_diffuse_velocity4_target = randi_range(-50, 200)
		
		outline_top_overflow = Globals.random_bool(9, 1)
		outline_bottom_overflow = Globals.random_bool(9, 1)
		outline_left_overflow = Globals.random_bool(9, 1)
		outline_right_overflow = Globals.random_bool(9, 1)
	
	is_ready = true


func _process(delta: float) -> void:
	if is_ready:
		deco_diffuse(delta)


func deco_create():
	outline_bottom.size.x = outline_bottom_start_size.x - 64
	outline_bottom.position.x = outline_bottom_start_pos.x + 32
	outline_bottom.position.y = outline_bottom_start_pos.y - 8
	outline_top.size.x = outline_top_start_size.x - 64
	outline_top.position.x = outline_top_start_pos.x + 32
	outline_left.size.y = outline_left_start_size.y - 64
	outline_left.position.y = outline_left_start_pos.y + 32
	outline_right.size.y = outline_right_start_size.y - 64
	outline_right.position.x = outline_right_start_pos.x - 8
	outline_right.position.y = outline_right_start_pos.y + 32
	
	edge_top_left.rotation_degrees = 90
	edge_top_right.rotation_degrees = 180
	edge_bottom_left.rotation_degrees = 0
	edge_bottom_right.rotation_degrees = -90
	
	edge_top_right.position.x = outline_top.size.x + 32
	edge_top_right.position.y = edge_top_right_start_pos.y + 32
	edge_bottom_right.position.x = outline_bottom.size.x
	edge_bottom_right.position.y = edge_bottom_right_start_pos.y + 8
	edge_bottom_left.position.x = edge_bottom_left_start_pos.x - 32
	edge_bottom_left.position.y = edge_bottom_left_start_pos.y - 24
	
	if randomize_basic:
		
		#if Globals.random_bool(1, 1):
			#scale.x *= -1
			#position.x += size.x
		#if Globals.random_bool(1, 1):
			#scale.y *= -1
			#position.y += size.y
		
		if outline_top_width != 8 : return
		
		var new_edge : Node
		
		if Globals.random_bool(3, 1):
			for x in randi_range(1, 4):
				new_edge = await Globals.spawn_scenes(outline_top, edge_top_left_filepath, 1, Vector2(0, 0), -1)
				new_edge.rotation_degrees = 90 * randi_range(0, 3)
				
				if Globals.debug_mode:
					var info = Label.new()
					info.text = str(new_edge.rotation_degrees)
					info.scale *= 4
					info.scale *= scale
					info.position.y += 100
					info.rotation_degrees = -new_edge.rotation_degrees
					new_edge.modulate = Color.YELLOW
					new_edge.add_child(info)
				
				if Globals.random_bool(1, 1) : new_edge.position.x = outline_top.size.x + 32
				new_edge.position.y = edge_top_right_start_pos.y + 32
				
				if new_edge.rotation_degrees == 0:
					if new_edge.position.x == 0:
						new_edge.position.x -= 8
						new_edge.position.y += 8
				elif new_edge.rotation_degrees == 90:
					if new_edge.position.x == 0:
						new_edge.position.y += 8
				elif new_edge.rotation_degrees == 180:
					if new_edge.position.x == 0:
						new_edge.position.x -= 8
		
		if Globals.random_bool(3, 1):
			for x in randi_range(0, 3):
				new_edge = await Globals.spawn_scenes(outline_top, edge_top_left_filepath, 1, Vector2(0, 0), -1)
				new_edge.rotation_degrees = 90 * randi_range(0, 3)
				new_edge.position.x = outline_bottom.size.x
				new_edge.position.y = edge_bottom_right_start_pos.y + 8
				
				if Globals.debug_mode:
					var info = Label.new()
					info.text = str(new_edge.rotation_degrees)
					info.scale *= 4
					info.scale *= scale
					info.position.y += 100
					info.rotation_degrees = -new_edge.rotation_degrees
					new_edge.modulate = Color.RED
					new_edge.add_child(info)
				
				new_edge.position.x = outline_top.size.x + 32
				new_edge.position.y = edge_top_right_start_pos.y + 32
				#if new_edge.rotation_degrees == 180 : new_edge.position.y -= 4
				if new_edge.rotation_degrees == 0 : new_edge.position.x -= 8
		
		if Globals.random_bool(3, 1):
			for x in randi_range(0, 3):
				new_edge = await Globals.spawn_scenes(outline_bottom, edge_top_left_filepath, 1, Vector2(0, 0), -1)
				new_edge.rotation_degrees = 90 * randi_range(0, 3)
				new_edge.position.x = edge_bottom_left_start_pos.x - 32
				new_edge.position.y = edge_bottom_left_start_pos.y - 24
				
				if Globals.debug_mode:
					var info = Label.new()
					info.text = str(new_edge.rotation_degrees)
					info.scale *= 4
					info.scale *= scale
					info.position.y += 100
					info.rotation_degrees = -new_edge.rotation_degrees
					new_edge.modulate = Color.GREEN
					new_edge.add_child(info)
				
				if Globals.random_bool(1, 1) : new_edge.position.x = outline_top.size.x + 32
				new_edge.position.y = edge_top_right_start_pos.y + 32
				#if new_edge.rotation_degrees == 180 : new_edge.position.y -= 4
				if new_edge.rotation_degrees == 0 : new_edge.position.x -= 8
		
		if Globals.random_bool(3, 1):
			for x in randi_range(0, 3):
				new_edge = await Globals.spawn_scenes(outline_bottom, edge_top_left_filepath, 1, Vector2(0, 0), -1)
				new_edge.rotation_degrees = 90 * randi_range(0, 3)
				
				if Globals.debug_mode:
					var info = Label.new()
					info.text = str(new_edge.rotation_degrees)
					info.scale *= 4
					info.scale *= scale
					info.position.y += 100
					info.rotation_degrees = -new_edge.rotation_degrees
					new_edge.modulate = Color.BLUE
					new_edge.add_child(info)
				
				new_edge.position.x = outline_top.size.x + 32
				new_edge.position.y = edge_top_right_start_pos.y + 32
				#if new_edge.rotation_degrees == 180 : new_edge.position.y -= 4
				if new_edge.rotation_degrees == 0 : new_edge.position.x -= 8


func adjust_deco_old():
	if width != -1 : outline_top.size.x = width
	if width != -1 : outline_bottom.size.x = width
	if height != -1 : outline_left.size.y = height
	if height != -1 : outline_right.size.y = height
	
	if randomize_basic:
		outline_top.size.x += randi_range(-50, 50)
		outline_bottom.size.x = outline_top.size.x
		outline_left.size.y += randi_range(-50, 50)
		outline_right.size.y = outline_left.size.y
	
	outline_right.position.x = outline_top.size.x
	outline_bottom.position.y = outline_left.size.y
	
	outline_bottom.size.x -= 64
	outline_bottom.position.x += 32
	outline_bottom.position.y -= 8
	outline_top.size.x -= 64
	outline_top.position.x += 32
	outline_left.size.y -= 64
	outline_left.position.y += 32
	outline_right.size.y -= 64
	outline_right.position.x -= 8
	outline_right.position.y += 32
	
	edge_top_left.rotation_degrees = 90
	edge_top_right.rotation_degrees = 180
	edge_bottom_left.rotation_degrees = 0
	edge_bottom_right.rotation_degrees = -90
	
	edge_top_right.position.x = outline_top.size.x + 32
	edge_top_right.position.y += 32
	edge_bottom_right.position.x = outline_bottom.size.x
	edge_bottom_right.position.y += 8
	edge_bottom_left.position.x += -32
	edge_bottom_left.position.y += -24


var deco_diffuse_velocity1 : float = 0
var deco_diffuse_velocity1_target : float = 100
var deco_diffuse_velocity2 : float = 0
var deco_diffuse_velocity2_target : float = 100
var deco_diffuse_velocity3 : float = 0
var deco_diffuse_velocity3_target : float = 100
var deco_diffuse_velocity4 : float = 0
var deco_diffuse_velocity4_target : float = 100

@export var speed_multiplier1 : float = 1.0
@export var speed_multiplier2 : float = 1.0
@export var speed_multiplier3 : float = 1.0
@export var speed_multiplier4 : float = 1.0

@export var randomize_speed_multiplier : bool = false

func deco_diffuse(delta : float) -> void:
	for x in range(1, 5):
		deco_diffuse_accelerate(delta, x)
		deco_diffuse_move(delta)
		deco_diffuse_handle_toggle(x)

func deco_diffuse_move(delta : float) -> void:
	outline_top.size.x += deco_diffuse_velocity1 * delta / 10 * speed_multiplier1
	outline_bottom.size.x += deco_diffuse_velocity2 * delta / 10 * speed_multiplier2
	outline_left.size.y += deco_diffuse_velocity3 * delta / 10 * speed_multiplier3
	outline_right.size.y += deco_diffuse_velocity4 * delta / 10 * speed_multiplier4
	
	if not outline_top_overflow:
		if outline_top.size.x > outline_top_ready_size.x:
			outline_top.size.x = outline_top_ready_size.x
	if not outline_bottom_overflow:
		if outline_bottom.size.x > outline_bottom_ready_size.x:
			outline_bottom.size.x = outline_bottom_ready_size.x
	if not outline_left_overflow:
		if outline_left.size.y > outline_left_ready_size.y:
			outline_left.size.y = outline_left_ready_size.y
	if not outline_right_overflow:
		if outline_right.size.y > outline_right_ready_size.y:
			outline_right.size.y = outline_right_ready_size.y

func deco_diffuse_accelerate(delta : float, x : int) -> void:
	set("deco_diffuse_velocity" + str(x), move_toward(get("deco_diffuse_velocity" + str(x)), get("deco_diffuse_velocity" + str(x) +"_target"), 100 * delta))

func deco_diffuse_handle_toggle(x : int) -> void:
	if get("deco_diffuse_velocity" + str(x) +"_target") > 0:
		if get("deco_diffuse_velocity" + str(x)) >= get("deco_diffuse_velocity" + str(x) +"_target"):
			set("deco_diffuse_velocity" + str(x) + "_target", (randi_range(-10, -100)))
	
	elif get("deco_diffuse_velocity" + str(x) +"_target") < 0:
		if get("deco_diffuse_velocity" + str(x)) <= get("deco_diffuse_velocity" + str(x) +"_target"):
			set("deco_diffuse_velocity" + str(x) + "_target", (randi_range(10, 100)))


func deco_randomize_basic(multiplier : float = 1.0):
	outline_top.size.x += randi_range(-15, 15)
	outline_bottom.size.x = outline_top.size.x
	outline_left.size.y += randi_range(-15, 15)
	outline_right.size.y = outline_left.size.y
