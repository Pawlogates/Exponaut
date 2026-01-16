extends Button

@onready var text_manager: Control = $text_manager
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_disabled: Timer = $timer_disabled

@export var text_manager_message = "none"

var is_pressed = false
var is_focused = false

var on_focus_rotation_direction = 1

var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.debug1.connect(spawn_decoration.bind(true))
	Globals.message_debug("Text Manager message has been requested by a Button.")
	
	text_manager.create_message(text_manager_message)
	await get_tree().create_timer(0.1, true).timeout
	spawn_decoration()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if correct_pivot_offset or is_focused : pivot_offset = size / 2
	
	if is_focused:
		rotation_degrees = lerp(rotation_degrees, 5.0 * on_focus_rotation_direction, delta * 10)
	else:
		rotation_degrees = lerp(rotation_degrees, 0.0, delta * 20)


func _on_button_down() -> void:
	if not enabled : return
	
	is_pressed = true
	#modulate.a = 0.5


func _on_button_up() -> void:
	is_pressed = false
	#modulate.a = 1.0
	animation_player.play("clicked")
	
	enabled = false # This is needed so that the rotation animation doesnt repeat too often.
	timer_disabled.start()


func _on_focus_entered() -> void: # Note: This does NOT trigger on hovering over the button with mouse.
	if not enabled : return
	
	is_focused = true
	modulate.a = 0.5


func _on_focus_exited() -> void:
	is_focused = false
	modulate.a = 1.0
	
	enabled = false # This is needed so that the rotation animation doesnt repeat too often.
	timer_disabled.start()


func _on_mouse_entered() -> void: # This does trigger on hovering over the button with mouse...
	if not enabled : return
	
	is_focused = true
	modulate.a = 0.5
	
	on_focus_rotation_direction = randi_range(-1, 1)
	Globals.message_debug(on_focus_rotation_direction)
	
	while not on_focus_rotation_direction: # Restart if rolled direction is equal to 0.
		on_focus_rotation_direction = randi_range(-1, 1)


func _on_mouse_exited() -> void:
	is_focused = false
	modulate.a = 1.0
	
	enabled = false # This is needed so that the rotation animation doesnt repeat too often.
	timer_disabled.start()


var correct_pivot_offset = false

func _on_animation_player_current_animation_changed(name: String) -> void:
	correct_pivot_offset = true


var gear_fail_chance = 0.999

func spawn_decoration(delete_old : bool = true):
	if delete_old:
		Globals.message_debug("Deleting old button decorations.")
		for node in get_children():
			if "type" in node:
				if node.type == "gear":
					node.queue_free()
	
	else:
		Globals.message_debug("Leaving old button decorations.")
	
	for x in range(int(size.x)):
		
		if randf_range(0, int(size.x)) > int(size.x) * gear_fail_chance:
			
			var scene = Globals.scene_gear
			
			var rolled_gear_type_id = randi_range(1, 5)
			if rolled_gear_type_id == 1: # Because there is no "gear1.tscn" scene.
				scene = Globals.scene_gear
			else:
				scene = Globals.get("scene_gear" + str(rolled_gear_type_id))
			
			var gear = scene.instantiate()
			
			gear.position.x = x
			
			if Globals.random_bool(1, 1):
				gear.position.y = 0
			else:
				gear.position.y = size.y
			
			gear.scale.x = randf_range(0.25, 1.25) / 4
			gear.scale.y = gear.scale.x
			
			gear.z_index = z_index + randi_range(-1, 1)
			
			add_child(gear)
			
			gear.play_anim(true) # The bool decides whether all of the decoration's animations will be randomized.
			
			Globals.message_debug(str("Spawning gear button decoration... (Chance of success: %s)" % gear_fail_chance))


func _on_timer_disabled_timeout() -> void:
	enabled = true
