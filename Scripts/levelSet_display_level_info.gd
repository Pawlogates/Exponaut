extends Control

@onready var l_name: RichTextLabel = $label_container/name
@onready var l_type: RichTextLabel = $label_container/type
@onready var l_score_best: RichTextLabel = $label_container/score_best
@onready var l_score_target: RichTextLabel = $label_container/score_target
@onready var l_time_best: RichTextLabel = $label_container/time_best
@onready var l_time_target: RichTextLabel = $label_container/time_target
@onready var l_creator: RichTextLabel = $label_container/creator
@onready var l_message: RichTextLabel = $label_container/message

@onready var c_preview: Timer = $cooldown_preview

var levelSet_id = "none"

var level_number = 0
var level_id = "none" # Example: "MAIN_1".

var level_state = -1
var level_score = -1
var level_score_target = -1
var level_time = -1
var level_time_target = -1
var level_rank = "none"
var level_rank_value = -1
var level_name = "none"
var level_type = "none"
var level_creator = "none"
var level_message = "none"
var level_difficulty = "none"

var level_icon_id = 0
var level_icon_position_x = 0
var level_icon_position_y = 0

var level_unlockMethod_previous = true
var level_unlockMethod_portal_in_level_id = "none"
var level_unlockMethod_key_in_level_id = "none"
var level_unlockMethod_score_in_level_id = "none"
var level_unlockMethod_score_in_levelSet_id = "none"
var level_unlockMethod_score_in_overworld_levelSet_id = "none"
var level_unlockMethod_time_in_level_id = "none"
var level_unlockMethod_time_in_levelSet_id = "none"

var level_saved_major_collectibles = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var level_info_major_collectibles = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] # Each value represents a major collectible SLOT, which should always match a major collectible placed in the matching level.

var unlocked = false

func _ready() -> void:
	if level_state > -1 : unlocked = true

func _physics_process(delta: float) -> void:
	pass


func _on_cooldown_preview_timeout() -> void:
	%bg.modulate.a += 0.01
