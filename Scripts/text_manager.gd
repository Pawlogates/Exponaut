extends Control

@export var text_full = "" # This is the main text property which should be targeted when instantiating this scene.

var text_simple = "none"
var last_text_full = "none"

var letter_x = 40
var letter_y = 40

var character_id = 0

func _ready() -> void:
	Globals.debug1.connect(create_message)
	
	if text_full != "":
		create_message(text_full)

func _physics_process(delta: float) -> void:
	pass

var current_character_is_rule_name = false
var current_rule = "none"

func create_message(message = last_text_full):
	#get_tree().paused = true
	
	Globals.message_debug("Creating a message using a Text Manager... Message's FULL text: '%s'" % message)
	if message != "":
		last_text_full = message
	
	for node in $row1.get_children():
		node.queue_free()
	
	$row1.size.x = letter_x * len(text_full)
	
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
	
		if current_rule == "[anim_fade_out_up]" or current_rule == "[/]" or current_rule == "":
			Globals.message_debug("A specific rule is causing a text container letter to delay the spawn of the rest.")
			await get_tree().create_timer(0.025, true).timeout
	
	#get_tree().paused = false


func add_letter(character):
	var letter = Globals.scene_text_manager_character.instantiate()
	$row1.add_child(letter)
	print(current_rule)
	
	letter.character.text = str(character)
	
	for anim_name in Globals.l_animation_name_general:
		if current_rule == str("[anim_%s]" % anim_name):
			
			letter.animation_player.play(anim_name)
	
	if not current_rule == "[anim_fade_out_up]" and not current_rule == "[/]" and not current_rule == "":
		letter.animation_player.advance(float(character_id) / 20)
	
	character_id += 1
