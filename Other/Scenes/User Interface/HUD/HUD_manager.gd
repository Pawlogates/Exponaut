extends CanvasLayer

@onready var player_main: Control = $player_main

@onready var animation_player: AnimationPlayer = $animation_ui

@onready var container_time: CenterContainer = $container_time
@onready var label_level_time: Label = %label_level_time

@onready var total_collectibles_collected: Label = %TotalCollectibles_collected


var active = false


func _ready() -> void:
	Globals.gameState_changed.connect(on_gameState_changed)
	Globals.entity_collected.connect(on_entity_collected)
	Globals.reset_puzzle_finished.connect(on_reset_puzzle_finished)
	Globals.level_started.connect(on_level_started)
	
	animation_player.play("show")
	
	await get_tree().create_timer(1.0, true).timeout
	
	update_collected_collectibles()


func _on_animation_ui_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		Globals.dm("Deleting the HUD.")
		queue_free()


func on_entity_collected():
	update_collected_collectibles()

func on_gameState_changed():
	update_collected_collectibles()

func on_reset_puzzle_finished():
	update_collected_collectibles()

func on_level_started():
	update_collected_collectibles()

func update_collected_collectibles():
	total_collectibles_collected.text = str(Globals.level_collected_collectibles) + " / " + str(Globals.total_collectibles_level)
	
	if Globals.level_collected_collectibles == Globals.total_collectibles_level:
		total_collectibles_collected.modulate = Color.GREEN
		total_collectibles_collected.material = Globals.material_cycle_yellow_orange
	else:
		total_collectibles_collected.modulate = Color.WHITE
		total_collectibles_collected.material = null
