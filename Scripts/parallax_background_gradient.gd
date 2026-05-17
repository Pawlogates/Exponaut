extends CanvasLayer

@onready var main: ParallaxBackground = $main
@onready var main_layer: ParallaxLayer = %main_layer
@onready var texture: TextureRect = $main/main_layer/texture


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.World.camera.zoom.x == 1:
		main_layer.motion_offset.x += 100 * delta
		main_layer.motion_offset.y += 20 * delta
