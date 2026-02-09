extends CanvasLayer

@onready var animation_ui: AnimationPlayer = $animation_ui
@onready var bg: ColorRect = $bg
@onready var close: Button = $close

@onready var label_n1: Label = $"names/1"
@onready var label_n2: Label = $"names/2"
@onready var label_n3: Label = $"names/3"
@onready var label_n4: Label = $"names/4"
@onready var label_n5: Label = $"names/5"
@onready var label_n6: Label = $"names/6"
@onready var label_n7: Label = $"names/7"
@onready var label_n8: Label = $"names/8"
@onready var label_n9: Label = $"names/9"
@onready var label_n10: Label = $"names/10"
@onready var label_n11: Label = $"names/11"
@onready var label_n12: Label = $"names/12"
@onready var label_n13: Label = $"names/13"
@onready var label_n14: Label = $"names/14"
@onready var label_n15: Label = $"names/15"
@onready var label_n16: Label = $"names/16"
@onready var label_n17: Label = $"names/17"
@onready var label_n18: Label = $"names/18"
@onready var label_n19: Label = $"names/19"
@onready var label_n20: Label = $"names/20"

@onready var label_v1: Label = $"values/1"
@onready var label_v2: Label = $"values/2"
@onready var label_v3: Label = $"values/3"
@onready var label_v4: Label = $"values/4"
@onready var label_v5: Label = $"values/5"
@onready var label_v6: Label = $"values/6"
@onready var label_v7: Label = $"values/7"
@onready var label_v8: Label = $"values/8"
@onready var label_v9: Label = $"values/9"
@onready var label_v10: Label = $"values/10"
@onready var label_v11: Label = $"values/11"
@onready var label_v12: Label = $"values/12"
@onready var label_v13: Label = $"values/13"
@onready var label_v14: Label = $"values/14"
@onready var label_v15: Label = $"values/15"
@onready var label_v16: Label = $"values/16"
@onready var label_v17: Label = $"values/17"
@onready var label_v18: Label = $"values/18"
@onready var label_v19: Label = $"values/19"
@onready var label_v20: Label = $"values/20"

var name1 = "none"
var name2 = "none"
var name3 = "none"
var name4 = "none"
var name5 = "none"
var name6 = "none"
var name7 = "none"
var name8 = "none"
var name9 = "none"
var name10 = "none"
var name11 = "none"
var name12 = "none"
var name13 = "none"
var name14 = "none"
var name15 = "none"
var name16 = "none"
var name17 = "none"
var name18 = "none"
var name19 = "none"
var name20 = "none"

var value1 = "none"
var value2 = "none"
var value3 = "none"
var value4 = "none"
var value5 = "none"
var value6 = "none"
var value7 = "none"
var value8 = "none"
var value9 = "none"
var value10 = "none"
var value11 = "none"
var value12 = "none"
var value13 = "none"
var value14 = "none"
var value15 = "none"
var value16 = "none"
var value17 = "none"
var value18 = "none"
var value19 = "none"
var value20 = "none"


func _ready() -> void:
	update_labels()
	animation_ui.play("show")

func _physics_process(delta: float) -> void:
	pass


func _on_cooldown_refresh_timeout() -> void:
	if Globals.gameState_level:
		value1 = Globals.level_id
		value2 = Globals.World.get_entity_status_all()
		value3 = Globals.level_id
		value4 = Globals.level_id
		value5 = Globals.level_id
		value6 = Globals.level_id
		value7 = Globals.level_id
		value8 = Globals.level_id
		value9 = Globals.level_id
		value10 = Globals.level_id
		value11 = Globals.level_id
		value12 = Globals.Player.sprite.animation
		value13 = Globals.Player.state_walk
		value14 = Globals.Player.state_jump
		value15 = Globals.Player.state_fall
		value16 = Globals.Player.state_shoot
		value17 = Globals.Player.state_damage
		value18 = Globals.Player.state_crouch
		value19 = Globals.Player.state_crouch_walk
		value20 = Globals.Player.state_idle
	
	# Update the visible text of value labels.
	update_labels()

func update_labels():
	for id in range(1, 21): # Total (20) - 1, because it starts from 0.
		get("label_n" + str(id)).text = str(get("name" + str(id)))
		get("label_v" + str(id)).text = str(get("value" + str(id)))
	
	name1 = "Currently loaded level's ID: "
	name2 = "Total entities present in the currently loaded level: "
	name3 = "none"
	name4 = "none"
	name5 = "none"
	name6 = "none"
	name7 = "none"
	name8 = "none"
	name9 = "none"
	name10 = "none"
	name12 = "Current player sprite anim name: "
	name13 = "Walk state weight: "
	name14 = "Jump state weight: "
	name15 = "Fall state weight: "
	name16 = "Shoot state weight: "
	name17 = "Damage state weight: "
	name18 = "Crouch state weight: "
	name19 = "Crouch Walk state weight: "
	name20 = "Idle state weight: "


func _on_close_pressed() -> void:
	animation_ui.play("hide")


func _on_animation_ui_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		queue_free()
