extends Control

@onready var menu_bg: Control = $menu_bg
@onready var bg: ColorRect = $menu_bg/bg
@onready var animation_all: AnimationPlayer = $menu_bg/animation_all
@onready var hitbox: Area2D = $hitbox
@onready var sfx_manager: Node2D = $sfx_manager


var segment_number : int = 0
var block_global_pos : Vector2 = Vector2(0, 0)

var collected : bool = false

var block_color : Color = Color.WHITE
var block_on_collected_anim_name : String = "none"
var block_on_collected_anim_speed : float = -1.0

var block_score_value : int = -1

var solved : bool = false

func _ready() -> void:
	block_score_value = randi_range(1, 10)
	
	var label_score : Node = load("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn").instantiate()
	label_score.position.x += 6
	label_score.position.y += 16
	add_child(label_score)
	label_score.message("[anim_" + Globals.l_animation_name_general_all.pick_random() + "]" + str(block_score_value), -1, true, 24, randf_range(0.01, 0.5), randf_range(0.01, 0.5), randf_range(0.01, 0.5), 0.5)
	
	
	block_global_pos = global_position - Vector2(130, 60)
	
	bg.color = block_color
	bg.color *= 0.5
	bg.size = size * 0.9
	bg.position = Vector2(6, 6)
	
	#await get_tree().create_timer(0.5 + randf_range(0.01, 0.25) + float(segment_number) - (0.033 * float(segment_number) * float(segment_number)), true).timeout

func get_random_point_in_range(rect_size_multiplier : Vector2 = Vector2(1.0, 1.0), rect_size_base : Vector2 = Globals.window_size):
	var rect_size : Vector2 = rect_size_base * rect_size_multiplier
	return Vector2(randi_range(-rect_size.x / 2, rect_size.x / 2), randi_range(-rect_size.y / 2, rect_size.y / 2))

func _physics_process(delta: float) -> void:
	if collected : modulate.a -= delta


func _on_mouse_entered() -> void:
	if solved : handle_collected()

func handle_collected():
	block_global_pos = global_position - Vector2(130, 60)
	
	sfx_manager.sfx_play(Globals.sfx_jewel_collect2, randf_range(0.75, 1.0), randf_range(0.75, 1.25))
	
	if is_instance_valid(Globals.main_scene):
		Globals.spawn_scenes(Globals.main_scene, load("res://Other/Particles/star_homing.tscn"), Globals.combo_tier, block_global_pos, 12, Globals.l_color_all.pick_random(), Vector2(randf_range(-0.95, -0.75), 0), 500, ["score_value"], [block_score_value])
		Globals.spawn_scenes(Globals.main_scene, load("res://Other/Effects/oneShot_enemy.tscn"), 1, block_global_pos, randf_range(0.25, 1.0), Globals.l_color_all.pick_random(), Vector2(randf_range(-0.95, -0.75), 0), 500)
	
	collected = true
	
	modulate *= 4
	scale /= 2
	position += Vector2(16, 16)
	z_index -= 10
	
	var experience_value : int = 10
	Overlay.hud_player_experience.experience_increase(experience_value + (randi_range(0, Globals.player_level * Globals.player_level)) + randi_range(-experience_value * 0.1, experience_value * 0.1))
	
	animation_all.speed_scale = block_on_collected_anim_speed
	#animation_all.play("general/rotate_away_up_right")
	animation_all.play("general/" + block_on_collected_anim_name)
	await get_tree().create_timer(2.0, true).timeout
	get_parent().delete_if_collected()
	queue_free()

func on_chain_placed():
	for node in hitbox.get_overlapping_areas():
		var block : Node = node.get_parent()
		block.handle_collected()
		handle_collected()


func _on_hitbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_hitbox_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
