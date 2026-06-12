extends Node2D

@onready var square: ColorRect = $square
@onready var container_orb_shadow: Node2D = $container_orb_shadow
@onready var container_rectangle: Node2D = $container_rectangle
@onready var back: Sprite2D = $back
@onready var front: ColorRect = $front
@onready var container_decoration: Node2D = $container_decoration
@onready var scan_visible: VisibleOnScreenNotifier2D = $scan_visible


@export_enum("dirt", "stone", "wood", "brick") var deco_type : String = "dirt"
@export_enum("main", "bg", "bg2", "fg", "fg2") var deco_layer : String = "main"

@export var scene_deco_part = preload("res://Other/Scenes/Random Decoration/random_decoration_part.tscn")
@export var deco_amount = 4
@export var deco_skip_chance = 0
@export var spread_position = true
@export var deco_spread = 16
@export var make_black = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scan_visible.visible = true
	#decoration_create()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_glow_shadow():
	if Globals.get_random_bool(25) : return
	Globals.spawn_scenes(container_decoration, load("res://Objects/Decorations/glow_shadow_orb_heavy.tscn"), 1, Vector2(randi_range(-200, 200), randi_range(-200, 200)), -1, Color(0, 0, 0, 0), Vector2(randf_range(-1, 1), randf_range(-1, 1)), 1, ["energy", "rotation_degrees"], [randf_range(0.0, 1.0), randf_range(-10, 10)], Vector2(0, 0), [Vector2(0, 0), Vector2(0, 0)], [Vector2(0, 0), Vector2(0, 0)], [Vector2(0, 0), Vector2(0, 0)], false)


func decoration_create():
	if deco_layer == "main":
		if Globals.get_random_bool(1) : Globals.spawn_scenes(container_decoration, load("res://Objects/Decorations/decoration_gear_random_type_tiny.tscn"), 1, Vector2(randi_range(-64, 64), randi_range(-32, 64)), -1)
		
		if is_instance_valid(back):
			back.queue_free()
		if is_instance_valid(front):
			front.modulate.a = 1
	
	# hack below
	if is_instance_valid(back):
		var sprite_texture_rect : Array = [-1, -1, 32, 32]
		
		if deco_type == "brick":
			sprite_texture_rect[1] = 9
			if Globals.get_random_bool(10) : sprite_texture_rect[0] = randi_range(0, 7)
			else : sprite_texture_rect[0] = 0
		
		elif deco_type == "dirt":
			sprite_texture_rect[1] = randi_range(0, 2)
		
			if sprite_texture_rect[1] == 0:
				if Globals.get_random_bool(50):
					sprite_texture_rect[0] = 0
					sprite_texture_rect[1] = 0
				else:
					sprite_texture_rect[0] = randi_range(0, 3)
					
					if sprite_texture_rect[1] == 1:
						sprite_texture_rect[0] = randi_range(0, 2)
					elif sprite_texture_rect[1] == 2:
						sprite_texture_rect[0] = randi_range(0, 1)
			else:
				sprite_texture_rect[0] = 0
		
		back.region_rect = Rect2(32 * sprite_texture_rect[0], 32 * sprite_texture_rect[1], sprite_texture_rect[2], sprite_texture_rect[3])
	
	
	if is_instance_valid(container_orb_shadow):
		for orb_shadow in container_orb_shadow.get_children():
			if Globals.random_bool(1, 3) : orb_shadow.queue_free()
	
	if is_instance_valid(container_rectangle):
		for orb_shadow in container_rectangle.get_children():
			if Globals.random_bool(3, 1) : orb_shadow.queue_free()
	
	var f_deco_amount : int = deco_amount
	
	while f_deco_amount > 0:
		f_deco_amount -= 1
		
		var deco_part = scene_deco_part.instantiate()
		
		if spread_position : deco_part.position = Vector2(randi_range(-deco_spread, deco_spread), randi_range(-deco_spread, deco_spread))
		
		if deco_layer == "bg":
			if deco_type == "dirt":
				if Globals.get_random_bool(5):
					spawn_glow_shadow()
			
			elif deco_type == "brick":
				if Globals.get_random_bool(1):
					spawn_glow_shadow()
		
		if Globals.random_bool(24, 1):
			deco_part.modulate = Color.BLACK
		
		else:
			deco_part.modulate.b = randf_range(0, 0.05)
			deco_part.modulate.r = deco_part.modulate.b - Globals.World.randomized_deco_fade_offset.y + randf_range(1, 0.0001 * (randi_range(-1200, 1200) + position.x))
			deco_part.modulate.g = deco_part.modulate.b - Globals.World.randomized_deco_fade_offset.x + randf_range(1, 0.0001 * (randi_range(-1200, 1200) + position.y))
			deco_part.modulate.a = randf_range(0, 0.05) + 0.1 + randf_range(0, 0.0001 * position.x - (00 + position.y) / 1000)
			#deco_part.modulate.a = clamp(deco_part.modulate.a, 0.01, 1)
		
		if Globals.random_bool(9, 1):
			deco_part.modulate.r /= randf_range(1.1, 10)
			deco_part.modulate.g /= randf_range(1.1, 10)
			deco_part.modulate.b /= randf_range(1.1, 10)
		
		if make_black:
			deco_part.modulate = Color.BLACK
			deco_part.modulate.a = randi_range(0.1, 1)
		
		if not Globals.get_random_bool(deco_skip_chance) : container_decoration.add_child(deco_part)

func decoration_delete():
	for node in container_decoration.get_children():
		node.queue_free()


func _on_scan_visible_screen_entered() -> void:
	decoration_create()


func _on_scan_visible_screen_exited() -> void:
	decoration_delete()
