extends Control

@onready var bar_experience: ColorRect = $container_bar/experience
@onready var bar_bg: ColorRect = $container_bar/bar_bg
@onready var bar_experience_bg: ColorRect = $container_bar/experience_bg
@onready var container_bar: Control = $container_bar # It doesn't seem to be centering anything on its own.
@onready var label_level: Label = $label_level
@onready var label_experience: Label = $label_experience


var level_current : int = 0
var experience_current : float = 0.0

var experience_next : float = 100.0
var experience_total : int = 0

var experience_next_total : int = 100 # Refers to the current level's experience requirement, and does NOT change depending on current experience.

var experience_bar_length : int = 600
var percent_experience_next : float = 1.0
var percentage_experience_next : float = 0.0

@onready var debug: Control = $debug
@onready var btn_increase_exp: Button = $debug/btn_increase_exp
@onready var btn_increase_level: Button = $debug/btn_increase_level
@onready var increase_value: TextEdit = $debug/increase_value
@onready var container_values: VBoxContainer = $debug/container_values


func _ready() -> void:
	on_level_next(false)

func _physics_process(delta: float) -> void:
	container_bar.modulate.r = move_toward(container_bar.modulate.r, 1, delta)
	container_bar.modulate.g = move_toward(container_bar.modulate.g, 1, delta)
	container_bar.modulate.b = move_toward(container_bar.modulate.b, 1, delta)
	
	bar_experience.color.r = move_toward(bar_experience.color.r, 1, delta * 2)
	bar_experience.color.g = move_toward(bar_experience.color.g, 0, delta * 2)
	bar_experience.color.b = move_toward(bar_experience.color.b, 0, delta * 2)
	
	#Globals.set_mouse_mode(true)
	
	if experience_current >= experience_next:
		on_level_next()
	
	container_bar.position.x = (1920 - experience_bar_length) / 2
	
	percentage_experience_next = (experience_current / percent_experience_next)
	
	bar_experience.size.x = experience_bar_length * (percentage_experience_next / 100.0)
	bar_experience_bg.size.x = bar_experience.size.x + 6
	
	btn_increase_exp.text = str(experience_current)
	btn_increase_level.text = str(level_current)
	
	label_experience.text = str(int(experience_current)) + " / " + str(int(experience_next))

func _on_btn_increase_exp_pressed() -> void:
	if increase_value.text.is_valid_float():
		experience_current += float(increase_value.text)


func _on_btn_increase_level_pressed() -> void:
	if increase_value.text.is_valid_float():
		level_current += float(increase_value.text)


func on_level_next(effects : bool = true):
	if effects : Globals.spawn_message_object("LEVEL UP!", 1.0, self, Vector2(960, 0))
	
	experience_current = 0
	level_current += 1
	Globals.player_level = level_current
	experience_next = 75 * level_current * level_current
	percent_experience_next = experience_next / 100.0
	experience_bar_length = 200.0 + level_current * 50.0
	experience_bar_length = clamp(experience_bar_length, 100, 800)
	bar_bg.size.x = experience_bar_length * 1.025
	$container_bar/bar_bg/deco_edge_right.position.x = experience_bar_length * 1.025 + 2
	$container_bar/bar_bg/deco_middle.scale.x = float(experience_bar_length * 1.025) / float(173)
	$container_bar/shadow.scale.x = float(experience_bar_length * 1.025) / float(173)
	label_level.text = str(level_current)
	
	if effects:
		Globals.spawn_scenes(container_bar, Globals.scene_particle_star, level_current, Vector2(experience_bar_length / 2, 8))
		Globals.spawn_scenes(container_bar, Globals.scene_particle_special, level_current, Vector2(experience_bar_length / 2, 8), 5, Color.WHITE, Vector2(0, 0), 11, ["rotation_degrees"], [180])
		Globals.spawn_scenes(Globals.World, Globals.scene_particle_homing_square, level_current, Globals.Player.position, 10, Globals.l_color_all.pick_random(), Vector2(0, 0), 10)
		Globals.spawn_scenes(container_bar, load("res://Other/Effects/display_text_falling.tscn"), 1, Vector2(experience_bar_length / 2, 128 - 4 * level_current), 20, Color(0, 0, 0, 0), Vector2(0.5, 0.5) + Vector2(0.025, 0.025) * level_current, 10, ["text_message", "gravity", "rotation_speed", "rotation_degrees"], [str(level_current), -50, 0.1 * level_current, 45])
		
		$sfx_manager.sfx_play(Globals.sfx_medium_effect3, 2, 2)
		$sfx_manager.sfx_play(Globals.sfx_medium_effect3, 2, 1)
		$sfx_manager.sfx_play(Globals.sfx_medium_effect3, 2, 0.5)
		$sfx_manager.sfx_play(Globals.sfx_beam_enabled, 0.025 * level_current, 1.5)
	
	container_bar.modulate = Color.GREEN
	bar_experience.color = Color.YELLOW * 4


func experience_increase(value : int = 125):
	experience_current += value
	
	bar_bg.color = Color.BLACK.blend(Color.GOLD * percentage_experience_next / 75)
	Globals.spawn_scenes(container_bar, load("res://Other/Effects/display_text_falling.tscn"), 1, Vector2(randi_range(-240, 240), randi_range(-32, -128)) + Vector2(experience_bar_length / 2, 64 + 2 * level_current), 20, Color(0, 0, 0, 0), clamp(Vector2(-0.9, -0.9) + Vector2(0.00025, 0.00025) * value, Vector2(-0.9, -0.9), Vector2(0, 0)), 10, ["text_message", "gravity", "rotation_speed", "rotation_degrees", "font_basic"], ["+" + str(value) + " exp", -50, 1 * level_current, randi_range(0, 360), true])
	Globals.spawn_scenes(container_bar, Globals.scene_particle_special, 1)
