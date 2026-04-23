extends Control

@onready var insert_player_name: TextEdit = $insert_player_name
@onready var sfx_manager: Node2D = $sfx_manager
@onready var animation_all: AnimationPlayer = $animation_all


var player_name = "none"

var start_pos : Vector2 = Vector2(-1, -1)


var effect_hide_active : bool = false
var effect_hide_direction : Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1))
var effect_hide_rotation : int = randi_range(-360, 360)


func _ready() -> void:
	Globals.gameState_typing = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	for node in get_tree().get_nodes_in_group("menu_player_name"):
		if node != self:
			node.queue_free()
	
	move_to_front()
	
	if start_pos == Vector2(-1, -1):
		start_pos = position

func _process(delta: float) -> void:
	if effect_hide_active:
		position += effect_hide_direction * 1500 * delta
		rotation_degrees = lerp(rotation_degrees, float(effect_hide_rotation), delta)
	
	else:
		scale = scale.lerp(Vector2(1, 1), delta * 4)
		position = position.lerp(start_pos, delta * 4)


func _on_insert_player_name_text_changed() -> void:
	scale.y *= randf_range(1, 1.05)
	scale.x *= randf_range(1, 1.1)
	if scale.x > 1.5 : scale.x = 1.5
	if scale.y > 1.5 : scale.y = 1.5
	position.x += randf_range(-5, 5)
	position.y += randf_range(-5, 5)
	sfx_manager.sfx_play(Globals.sfx_slash, 1, randf_range(0.8, 1.2))

func on_text_confirmed():
	if insert_player_name.text != "":
		SaveData.player_name = insert_player_name.text
	else:
		SaveData.player_name = Globals.l_color_all.pick_random() + "_" + str(randi_range(0, 9999))
	
	var filepath = "user://player_info.json"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	SaveData.save_file(filepath, {"name" : SaveData.player_name})
	
	Globals.message("Player name has been set to: " + str(SaveData.player_name) + ".", -1, Vector2(0, 0), 4, 8)
	
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Globals.gameState_typing = false
	
	
	Globals.handle_spawn_menu(false)
	await get_tree().create_timer(0.5, true).timeout
	effect_hide_active = true
	await get_tree().create_timer(4, true).timeout
	queue_free()


func _on_btn_confirm_pressed() -> void:
	on_text_confirmed()
