extends Control

@onready var c_create_message: Timer = $cooldown_create_message

@export var text_full = "" # This is the main text property which should be targeted when instantiating this scene.
@export var text_alignment = 0
@export var text_animation_sync = true

@export var cooldown_remove_message : float = -1.0
@export var cooldown_create_message : float = -1.0

@export var character_anim_speed_scale : float = 1.0
@export var character_anim_backwards : bool = false
@export var text_animation_add_offset : float = -1.0


var text_visible = "none"
var last_text_full = "none"

var letter_x = 20
var letter_y = 20

var character_id = 0

var sfx_limit = 0

func _ready() -> void:
	Globals.message_debug("Connecting debug signal 1 to a Text Manager, with the target function being 'create_message'.")
	Globals.debug1.connect(debug_create_message)
	
	sfx_limit = 0
	
	if text_alignment : $row1.alignment = text_alignment
	
	if text_full != "":
		create_message(text_full) # This rarely if ever actually executes. Most of the time, the "create_message()" function is requested by the node instantiating the Text Manager.
	
	if cooldown_remove_message != -1.0: # It should only ever be equal to "0" if the message consists of a single visible character, otherwise the text is not ready for this delay.
		if cooldown_remove_message != 0.0 : await get_tree().create_timer(cooldown_remove_message, true).timeout
		
		for character in $row1.get_children():
			character.removable = true
			await get_tree().create_timer(0.01, true).timeout
		
		await get_tree().create_timer(4, true).timeout
		queue_free()


func _physics_process(delta: float) -> void:
	pass


var current_character_is_rule_name = false
var current_rule = "none"

func create_message(message = last_text_full):
	if cooldown_create_message != -1.0:
		Globals.message_debug(str("Text Manager's message creation has been delayed by %s") % cooldown_create_message, 3)
		c_create_message.wait_time = cooldown_create_message
		c_create_message.start()
		await c_create_message.timeout
	
	Globals.message_debug("Creating a message using a Text Manager... Message's FULL text: '%s'" % message)
	
	if message != "":
		last_text_full = message
	
	for node in $row1.get_children():
		node.queue_free()
	
	character_id = 0
	
	for character in message:
		if current_character_is_rule_name:
			current_rule += character
			
			if character == "]" : current_character_is_rule_name = false
			continue
		
		if character == "[": # Rule starting point.
			current_rule = ""
			current_character_is_rule_name = true
			current_rule += character
			continue
		
		add_letter(character)
		
		#if current_rule == "[anim_fade_out_up]" or current_rule == "[/]" or current_rule == "":
		#Globals.message_debug("A specific rule is causing a text container letter to delay the spawn of the rest.")
		
		await get_tree().create_timer(0.01, true).timeout


func add_letter(character):
	var letter = Globals.scene_text_manager_character.instantiate()
	$row1.add_child(letter)
	
	letter.character.text = str(character)
	
	for anim_name in Globals.l_animation_name_general:
		if current_rule == str("[anim_%s]" % anim_name):
			
			letter.animation_player.speed_scale = character_anim_speed_scale
			
			if character_anim_backwards : letter.animation_player.play_backwards(anim_name)
			else : letter.animation_player.play(anim_name)
	
	#if not current_rule == "[anim_fade_out_up]" and not current_rule == "[/]" and not current_rule == "":
	
	if text_animation_sync:
		letter.animation_player.advance(float(character_id * character_anim_speed_scale) / 10) # 20
		
	if text_animation_add_offset != -1.0:
		letter.animation_player.advance(text_animation_add_offset)
	
		#if sfx_limit <= 0:
			#letter.cooldown_sfx.wait_time = float(character_id) / 20
			#letter.cooldown_sfx.start()
			
			#sfx_limit = 5 + randi_range(0, 4)
	
	if sfx_limit <= 0:
		letter.sfx.play()
		
		sfx_limit = 10 + randi_range(-10, 20)
	
	character_id += 1
	sfx_limit -= 1


func debug_create_message():
	if not debug_available : return
	
	create_message()
	
	debug_available = false
	$cooldown_debug_available.start()


var debug_available = true

func _on_cooldown_debug_available_timeout() -> void:
	debug_available = true
