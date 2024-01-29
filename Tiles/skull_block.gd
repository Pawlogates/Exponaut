extends StaticBody2D

@export var is_active = true

var effect_dustScene = preload("res://effect_dust.tscn")
var effect_dust = effect_dustScene.instantiate()

var starParticleScene = preload("res://particles_special_multiple.tscn")
var starParticle = starParticleScene.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_active:
		%Sprite2D.region_rect = Rect2(384, 896, 64, 64)
		%CollisionShape2D.disabled = false
	
	else:
		%Sprite2D.region_rect = Rect2(448, 896, 64, 64)
		%CollisionShape2D.disabled = true



func skull_block_toggle():
	if not is_active:
		%Sprite2D.region_rect = Rect2(384, 896, 64, 64)
		%CollisionShape2D.disabled = false
		is_active = true
	
	else:
		%Sprite2D.region_rect = Rect2(448, 896, 64, 64)
		%CollisionShape2D.disabled = true
		is_active = false
	
	var dust = effect_dustScene.instantiate()
	dust.anim_slow = true
	add_child(dust)
	
	var stars = starParticleScene.instantiate()
	add_child(stars)

