extends Node2D

@export var motion_scale_x = 0.033
@export var motion_scale_y = 0.033


# Called when the node enters the scene tree for the first time.
func _ready():
	$darkDecoParallax/ParallaxLayer.motion_scale = Vector2(motion_scale_x, motion_scale_y)
	$darkDecoParallax/ParallaxLayer.motion_offset = position
	
	$darkDecoParallax.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
