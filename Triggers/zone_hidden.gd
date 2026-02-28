extends Node2D

@onready var timer_hidden: Timer = $timer_hidden
@onready var sfx_manager: Node2D = $sfx_manager
@onready var sprite: Sprite2D = $sprite
@onready var collision: CollisionShape2D = $scan/collision


@export var sprite_texture_region = Rect2(0, 0, 64, 64) # Replace the "0"s with a multiple of "64", depending on which tile (image part) should be used.

@export var uncover_on_proximity = true
@export var uncover_on_proximity_distance = Vector2(0.5, 0.5) # Measured in tiles (64px).

@export var uncover_on_timeout = false
@export var uncover_on_timeout_cooldown = 4.0
@export var uncover_on_timeout_start_on_proximity = false

@export var hidden_opacity = 1.0
@export var uncovered_opacity = 0.0

@export var on_uncovered_uncover_connected = true


var is_hidden = true

var connected_id = -1


func _ready() -> void:
	collision.scale = uncover_on_proximity_distance
	sprite.region_rect = sprite_texture_region
	
	if not is_hidden : uncover()
	
	if uncover_on_timeout:
		
		timer_hidden.wait_time = uncover_on_timeout_cooldown
		
		if not uncover_on_timeout_start_on_proximity:
			timer_hidden.start()

func _process(delta: float) -> void:
	collision.scale = uncover_on_proximity_distance
	if is_hidden : modulate.a = move_toward(modulate.a, hidden_opacity, delta / 2)
	else : modulate.a = move_toward(modulate.a, uncovered_opacity, delta / 2)


func _on_scan_area_entered(area: Area2D) -> void:
	if not Globals.is_valid_entity(area) : return
	if not is_hidden : return
	
	Globals.dm("Player has entered a Hidden Zone.")
	print("ENTERED")
	
	if uncover_on_timeout:
		if uncover_on_timeout_start_on_proximity:
			Globals.dm("Starting a Hidden Zone timer. The zone will be uncovered on timeout.")
			timer_hidden.start()
	
	if uncover_on_proximity:
		if not uncover_on_timeout_start_on_proximity:
			uncover(true)

func _on_timer_hidden_timeout() -> void:
	uncover(true)


func uncover(master_zone : bool = false):
	if not is_hidden : return
	is_hidden = false
	
	if master_zone:
		uncover_connected()
		
		sfx_manager.sfx_play(Globals.sfx_secret, 1.0, 0.5)


func _on_scan_connected_area_entered(area: Area2D) -> void:
	if not area.is_in_group("zone_hidden_scan_connected") : return
	if connected_id != -1 : return
	
	var target = area.get_parent()
	
	if target.connected_id == -1:
		connected_id = randi_range(0, 9999)
		target.connected_id = connected_id
	else:
		connected_id = target.connected_id
	
	Globals.dm("The Connection ID of this Hidden Zone is: " + str(connected_id))


func uncover_connected():
	if connected_id == -1 : return
	
	Globals.World.uncover_matching_id.emit(connected_id)


func _on_scan_exact_area_entered(area: Area2D) -> void:
	if not Globals.is_valid_entity(area) : return
	if not is_hidden : return
	
	uncover(true)
