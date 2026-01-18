extends Control

@onready var decoration_main: Polygon2D = $decoration/decoration_main
@onready var decoration_fg: Polygon2D = $decoration/decoration_main/decoration_fg
@onready var decoration_bg: Polygon2D = $decoration/decoration_main/decoration_bg
@onready var decoration_bg2: Polygon2D = $decoration/decoration_main/decoration_bg2

var decoration_polygon_border = 2
var decoration_polygon_spread = 5


func _ready() -> void:
	create_decoration_polygons()


func create_decoration_polygons():
	# Adjusting decoration length to the actual button length.
	decoration_main.polygon[0] = Vector2(0, 0) + Vector2(randi_range(-decoration_polygon_spread, decoration_polygon_spread), randi_range(-decoration_polygon_spread, decoration_polygon_spread))
	decoration_main.polygon[1] = Vector2(size.x, 0) + Vector2(randi_range(-decoration_polygon_spread, decoration_polygon_spread), randi_range(-decoration_polygon_spread, decoration_polygon_spread))
	decoration_main.polygon[2] = size + Vector2(randi_range(-decoration_polygon_spread, decoration_polygon_spread), randi_range(-decoration_polygon_spread, decoration_polygon_spread))
	decoration_main.polygon[3] = Vector2(0, size.y) + Vector2(randi_range(-decoration_polygon_spread, decoration_polygon_spread), randi_range(-decoration_polygon_spread, decoration_polygon_spread))
	
	# Randomizing polygon verticles.
	decoration_bg.polygon[0] = decoration_main.polygon[0] + Vector2(-decoration_polygon_border, -decoration_polygon_border)
	decoration_bg.polygon[1] = decoration_main.polygon[1] + Vector2(decoration_polygon_border, -decoration_polygon_border)
	decoration_bg.polygon[2] = decoration_main.polygon[2] + Vector2(decoration_polygon_border, decoration_polygon_border)
	decoration_bg.polygon[3] = decoration_main.polygon[3] + Vector2(-decoration_polygon_border, decoration_polygon_border)
	
	decoration_bg2.polygon[0] = decoration_main.polygon[0] + Vector2(-decoration_polygon_border, -decoration_polygon_border)
	decoration_bg2.polygon[1] = decoration_main.polygon[1] + Vector2(decoration_polygon_border, -decoration_polygon_border)
	decoration_bg2.polygon[2] = decoration_main.polygon[2] + Vector2(decoration_polygon_border, decoration_polygon_border)
	decoration_bg2.polygon[3] = decoration_main.polygon[3] + Vector2(-decoration_polygon_border, decoration_polygon_border)
	
	decoration_fg.polygon[0] = decoration_main.polygon[0]
	decoration_fg.polygon[1] = decoration_main.polygon[1]
	decoration_fg.polygon[2] = decoration_main.polygon[2]
	decoration_fg.polygon[3] = decoration_main.polygon[3]

# UNUSED!
func effect_corrupted():
	decoration_main.uv[0] += Vector2(randi_range(-10, 10), randi_range(-10, 10))
	decoration_main.uv[1] += Vector2(randi_range(-10, 10), randi_range(-10, 10))
	decoration_main.uv[2] += Vector2(randi_range(-10, 10), randi_range(-10, 10))
	decoration_main.uv[3] += Vector2(randi_range(-10, 10), randi_range(-10, 10))
