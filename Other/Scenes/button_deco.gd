extends Polygon2D

var polygon1_position = Vector2(488, -40)
var polygon2_position = Vector2(488, 40)
var polygon3_position = Vector2(-488, 40)
var polygon4_position = Vector2(-488, -40)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().add_to_group("buttons_root")
	get_parent().add_to_group("buttons")
	add_to_group("buttons_deco")
	
	correct_polygons()
	
	#self_modulate.r = randf_range(0.5, 1)
	self_modulate.b = randf_range(0.5, 1)
	self_modulate.g = randf_range(0.5, 1)
	
	await get_tree().create_timer(2, false).timeout
	get_parent().get_child(0).z_index = z_index + 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func correct_polygons():
	polygon[0] = polygon1_position
	polygon[1] = polygon2_position
	polygon[2] = polygon3_position
	polygon[3] = polygon4_position
	
	polygon[0] += Vector2(randi_range(-20, 20), randi_range(-10, 10))
	polygon[1] += Vector2(randi_range(-20, 20), randi_range(-10, 10))
	polygon[2] += Vector2(randi_range(-20, 20), randi_range(-10, 10))
	polygon[3] += Vector2(randi_range(-20, 20), randi_range(-10, 10))
	
	$Polygon2D.polygon[0] = polygon[0] + Vector2(5, -5)
	$Polygon2D.polygon[1] = polygon[1] + Vector2(5, 5)
	$Polygon2D.polygon[2] = polygon[2] + Vector2(-5, 5)
	$Polygon2D.polygon[3] = polygon[3] + Vector2(-5, -5)
	
	$Polygon2D2.polygon[0] = $Polygon2D.polygon[0] + Vector2(5, -5)
	$Polygon2D2.polygon[1] = $Polygon2D.polygon[1] + Vector2(5, 5)
	$Polygon2D2.polygon[2] = $Polygon2D.polygon[2] + Vector2(-5, 5)
	$Polygon2D2.polygon[3] = $Polygon2D.polygon[3] + Vector2(-5, -5)
