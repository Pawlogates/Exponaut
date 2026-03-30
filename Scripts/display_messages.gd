extends CanvasLayer

var active : bool = false # Needed to ignore triggers from before the game state change.

@onready var bg: TextureRect = $container_message/bg
@onready var l_message_text: Label = $container_message/label_message_text
@onready var c_hide = $cooldown_hide
@onready var container_message: Control = $container_message
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	Globals.messages_added.connect(message_show)
	Globals.gameState_changed.connect(on_gameState_changed)
	
	if Globals.gameState_start_screen:
		container_message.modulate = Color(0.5, 0.5, 0.5, 0.95)
	
	await get_tree().create_timer(1.0, true).timeout
	
	active = true


func message_show(message_text, pause_duration : float = 4.0, message_add_pos : Vector2 = Vector2(0, 0), anim_hide_cooldown : float = 8.0, anim_speed_scale : float = 1.0, camera_target_offset : Vector2 = Vector2(128, 64), camera_target_zoom : Vector2 = Vector2(3, 3), camera_target_rotation : float = 10.0, camera_start_speed_multiplier : float = 0.01):
	if not active : return
	
	l_message_text.text = str(message_text)
	
	if len(message_text) < 56:
		bg.size.x = 24 * len(message_text) + 24
		bg.position.x = (container_message.size.x - bg.size.x) / 2
		
		$container_message/bg/decoration_gear.visible = false
		$container_message/bg/decoration_gear2.visible = false
		$container_message/bg/decoration_gear3.visible = false
		$container_message/bg/decoration_gear4.visible = false
	
	else:
		bg.size.x = container_message.size.x
		bg.position.x = 0 + message_add_pos.x
		
		$container_message/bg/decoration_gear.visible = true
		$container_message/bg/decoration_gear2.visible = true
		$container_message/bg/decoration_gear3.visible = true
		$container_message/bg/decoration_gear4.visible = true
	
	bg.size.y = container_message.size.y
	
	container_message.size.y = 64 * len(message_text) / 56
	container_message.position.y = 896.0 - len(message_text) / 56 * 56 + message_add_pos.y
	
	animation_player.stop()
	animation_player.speed_scale = anim_speed_scale
	animation_player.play("show")
	
	c_hide.wait_time = anim_hide_cooldown
	c_hide.start()
	
	if not is_instance_valid(Globals.Player) : return
	
	if pause_duration: # Set to "0.0" to disable all pause and camera-related effects.
		get_tree().paused = true
		Overlay.animation("black_transparent_fade_in")
		Globals.Player.camera.effect(camera_target_offset, camera_target_zoom, camera_target_rotation, camera_start_speed_multiplier)
		
		#layer = 101
		
		await get_tree().create_timer(pause_duration, true).timeout
		
		if is_instance_valid(Globals.Player.camera) : Globals.Player.camera.effect(Vector2(0, 0), Vector2(1, 1), 0.0, 0.5)
		Overlay.animation("black_transparent_fade_out")
		get_tree().paused = false
		
		await get_tree().create_timer(4.0, true).timeout
		
		#layer = 25


func _on_timer_hide_timeout():
	animation_player.play("hide")


func on_gameState_changed():
	Globals.reload_node(self)
