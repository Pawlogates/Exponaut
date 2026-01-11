extends Control

@onready var screen_levelSet = get_parent()

@onready var l_name: RichTextLabel = $label_container/name
@onready var l_type: RichTextLabel = $label_container/type
@onready var l_score: RichTextLabel = $label_container/score
@onready var l_score_target: RichTextLabel = $label_container/score_target
@onready var l_time: RichTextLabel = $label_container/time
@onready var l_time_target: RichTextLabel = $label_container/time_target
@onready var l_creator: RichTextLabel = $label_container/creator
@onready var l_message: RichTextLabel = $label_container/message

@onready var c_preview: Timer = $cooldown_preview
@onready var preview: TextureRect = %preview
@onready var scan_valid: Area2D = $scan_valid
@onready var c_show: Timer = $cooldown_show

var levelSet_id = "none"

var level_number = 0
var level_id = "none" # Example: "MAIN_1".

var level_state = -1
var level_score = -1
var level_score_target = -1
var level_time = -1
var level_time_target = -1
var level_rank = "none"
var level_rank_value = -1
var level_name = "none"
var level_type = "none"
var level_creator = "none"
var level_message = "none"
var level_difficulty = "none"

var level_icon_id = 0
var level_icon_position_x = 0
var level_icon_position_y = 0

var level_unlockMethod_previous = true
var level_unlockMethod_portal_in_level_id = "none"
var level_unlockMethod_key_in_level_id = "none"
var level_unlockMethod_score_in_level_id = "none"
var level_unlockMethod_score_in_levelSet_id = "none"
var level_unlockMethod_score_in_overworld_levelSet_id = "none"
var level_unlockMethod_time_in_level_id = "none"
var level_unlockMethod_time_in_levelSet_id = "none"

var level_saved_major_collectibles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var level_info_major_collectibles = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # Each value represents a major collectible SLOT, which should always match a major collectible placed in the matching level.

var level_unlocked = false

var preview_active = false

var distance_display_mouse = 0
var distance_acceptable = 500
var distance_correction_multiplier = 25

var center_pos = Vector2(0, 0)
var mouse_pos = Vector2(0, 0)

func _ready() -> void:
	if Globals.debug_mode:
		modulate.a = 1.0
	
	#scan_valid.connect("area_entered", _on_scan_valid_area_entered)
	
	position = Vector2(randi_range(-1000, 1000), randi_range(-500, 500))
	
	if level_state > -1 : level_unlocked = true
	
	l_name.text = str(level_name)
	l_type.text = str(level_type)
	l_score.text = str(level_score)
	l_score_target.text = str(level_score_target)
	l_time.text = str(level_time)
	l_time_target.text = str(level_time_target)
	
	l_creator.text = str(level_creator)
	l_message.text = str(level_message)
	#l_difficulty.text = str(level_difficulty)

func _physics_process(delta: float) -> void:
	center_pos = position + size / 2
	mouse_pos = get_local_mouse_position() # Use this ONLY for drawing debug lines.
	
	distance_display_mouse = center_pos.distance_to(Globals.mouse_pos)
	
	if preview_active : preview.modulate.a += 0.01
	
	if ready_show and distance_correction_multiplier:
		
		if distance_display_mouse < distance_acceptable:
			
			if center_pos.x > Globals.mouse_pos.x:
				position.x += distance_correction_multiplier
			else:
				position.x -= distance_correction_multiplier
			
			if center_pos.y > Globals.mouse_pos.y:
				position.y += distance_correction_multiplier
			else:
				position.y -= distance_correction_multiplier
			
			distance_correction_multiplier *= 0.8
			if distance_correction_multiplier > 0:
				distance_correction_multiplier = clamp(distance_correction_multiplier, 1, 100)
			
			Globals.message_debug("Level info display is too close to the mouse. Adjusting...", 3)
	
	if Globals.debug_mode : queue_redraw() # Used to update the debug lines.


func _draw():
	if Globals.debug_mode:
		if distance_display_mouse > distance_acceptable:
			draw_line(size / 2, mouse_pos, Color(1.0, 1.0, 1.0, 1.0), 5.0, true)
		else:
			draw_line(size / 2, mouse_pos, Color(1.0, 0.0, 0.0, 1.0), 5.0, true)

func _on_cooldown_preview_timeout() -> void:
	preview_active = true


var overlapping_areas = []
var attempts_position = 0

func validate_position():
	if attempts_position > 10:
		Globals.message_debug("Warning: Failed to validate position of a level info display on time (10 failed attempts).", 2)
	
	attempts_position += 1
	
	position = Vector2(randi_range(-1000, 1000), randi_range(-500, 500))
	
	await get_tree().create_timer(0.01, true).timeout
	
	scan_valid.monitoring = false
	scan_valid.monitoring = true
	Globals.message_debug("Getting overlapping area2D nodes of the level info display at a currently tested position.")
	overlapping_areas = scan_valid.get_overlapping_areas()
	Globals.message_debug(str("Found %s overlapping area2D nodes." % str(len(overlapping_areas))))
	
	c_show.start() # If this timer manages to timeout, it means the display is not touching any blocked zones.
	
	if position.distance_to(Globals.mouse_pos) > 400:
		await scan_valid.area_entered
	
	if ready_show : return
	
	for area in overlapping_areas:
		if area.is_in_group("blocked_zone_display"):
			Globals.message_debug("Touching a blocked zone, so this level info display position is invalid " + str(position), 2)
			
			if Globals.debug_mode:
				Globals.spawn_scenes(screen_levelSet, Globals.scene_effect_oneShot_enemy, 1, position + size / 2, 2)
		
		overlapping_areas.erase(area)
	
	validate_position() # Once started, this function will try (its stopped by an await) to repeat infinitely.

func _on_scan_valid_area_entered(area: Area2D) -> void:
	if area.is_in_group("blocked_zone_display"):
		overlapping_areas.append(area)
		if attempts_position < 1 and not ready_show : validate_position() # Further loops are started by the function itself.
		if ready_show : distance_correction_multiplier = 0

var ready_show = false # Whether the level info display is ready to be made visible in game.

func _on_cooldown_show_timeout() -> void:
	ready_show = true
	if not Globals.debug_mode:
		$AnimationPlayer.play("show")
	
	Globals.message_debug("Valid level info display position found and applied " + str(position), 3)
	Globals.message_debug("Level info display is ready to be made visible.")
