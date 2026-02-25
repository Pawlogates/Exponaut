extends Control

@onready var player_health: Control = $player_health
@onready var player_abilities: Control = $player_abilities


func _ready() -> void:
	Globals.debug_refresh.connect(debug_show)


func debug_show():
	player_health.debug_show()
	player_abilities.debug_show()
