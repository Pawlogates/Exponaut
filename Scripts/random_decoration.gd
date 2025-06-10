extends Node2D

@export var scene_deco_part = preload("res://Other/Scenes/Random Decoration/random_decoration_part.tscn")
@export var deco_amount = 4
@export var spread_position = true
@export var deco_spread = 16
@export var make_black = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	while deco_amount > 0:
		deco_amount -= 1
		
		var deco_part = scene_deco_part.instantiate()
		
		if spread_position : deco_part.position = Vector2(randi_range(-deco_spread, deco_spread), randi_range(-deco_spread, deco_spread))
		
		if make_black:
			deco_part.modulate.r = 0
			deco_part.modulate.g = 0
			deco_part.modulate.b = 0
		
		add_child(deco_part)
	
	
	$ColorRect.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
