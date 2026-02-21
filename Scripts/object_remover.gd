extends Area2D

@onready var cooldown_delete_target: Timer = $cooldown_delete_target


@export var target_node_name = "none"


var active = false
var finished = false
var target : Node2D


func _ready():
	set_process(false)

func _process(delta):
	if not finished and active:
		target.modulate.a = move_toward(target.modulate.a, 0.0, delta)


func _on_area_entered(area: Area2D) -> void:
	if not Globals.is_valid_entity(area) : return
	if active : return
	
	active = true
	
	if get_parent().get_node(target_node_name):
		target = get_parent().get_node(target_node_name)
	else:
		return
	
	cooldown_delete_target.start()
	set_process(true)


func _on_timer_timeout():
	finished = true
	target.queue_free()
	set_process(false)
