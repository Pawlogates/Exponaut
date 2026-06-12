extends CanvasLayer

@onready var HUD : Node
@onready var hud_display_messages : Node
@onready var hud_player_experience : Node
@onready var hud_player_health : Node
@onready var hud_player_abilities : Node

@onready var screen_color = $screen_color
@onready var animation_player = $AnimationPlayer

func _ready():
	Globals.gameState_changed.connect(reassign_general)
	
	reassign_general()
	await get_tree().create_timer(1.0, true).timeout
	reassign_general()
	
	if Globals.gameState_debug:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	screen_color.color.a = 0.0

func _physics_process(_delta: float) -> void:
	pass


# Called from anywhere outside of this script. Example: animation("black_fade_in", 1.0, false, true)
func animation(anim_name : String = "black_fade_out", speed : float = 1.0, play_backwards : bool = false, await_finished : bool = true, delay : float = 0.25, await_delay : float = 0.25):
	animation_player.stop()
	
	animation_player.speed_scale = speed
	
	if delay : await get_tree().create_timer(delay, true).timeout
	
	if play_backwards:
		animation_player.play_backwards(str(anim_name))
	else:
		animation_player.play(str(anim_name))
	
	if await_finished : await animation_player.animation_finished
	
	if await_delay : await get_tree().create_timer(await_delay, true).timeout


func reassign_general():
	HUD = get_tree().get_first_node_in_group("HUD")
	hud_display_messages = get_tree().get_first_node_in_group("display_messages")
	hud_player_health = get_tree().get_first_node_in_group("hud_player_health")
	hud_player_abilities = get_tree().get_first_node_in_group("hud_player_abilities")
	hud_player_experience = get_tree().get_first_node_in_group("hud_player_experience")
