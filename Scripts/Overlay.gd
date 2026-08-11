extends CanvasLayer

@onready var HUD : Node
@onready var display_messages : Node

@onready var screen_color = $screen_color
@onready var animation_player = $AnimationPlayer

func _ready():
	Globals.gameState_changed.connect(reassign_general)
	
	if Globals.gameState_debug:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	screen_color.color.a = 0.0

func _physics_process(_delta: float) -> void:
	pass


# Called from anywhere outside of this script. Example: animation("black_fade_in", 1.0, false, true)
func animation(anim_name : String = "black_fade_out", speed : float = 1.0, play_backwards : bool = false, await_finished : bool = true, delay : float = 0.25, await_delay : float = 0.25, transition_filepath : String = "none", transition_anim_speed : float = 1.0, transition_add_scale : Vector2 = Vector2(0, 0)):
	animation_player.speed_scale = speed
	
	if delay : await get_tree().create_timer(delay, true).timeout
	
	if play_backwards:
		animation_player.play_backwards(str(anim_name))
	else:
		animation_player.play(str(anim_name))
	
	if transition_filepath != "none":
		var transition : Node = await Globals.spawn_scenes(self, transition_filepath)
		#if anim_name == "black_fade_out" : transition.scale.x = -1
		transition.scale += transition_add_scale
		if transition_anim_speed != -1 : transition.anim_speed = transition_anim_speed
	
	if await_finished : await animation_player.animation_finished
	
	if await_delay : await get_tree().create_timer(await_delay, true).timeout


func reassign_general():
	HUD = get_tree().get_first_node_in_group("HUD")
	display_messages = get_tree().get_first_node_in_group("display_messages")
