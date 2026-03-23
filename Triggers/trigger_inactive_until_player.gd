extends Node2D

var active : bool = false
var entities_inside : Array = []


func _ready() -> void:
	await get_tree().create_timer(1, true).timeout
	active = true

func _physics_process(delta: float) -> void:
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	
	if Globals.is_valid_entity(area, ["entity"]):
		
		if active : return
		
		var target = area.get_parent()
		
		target.basic_on_inactive()
		target.enabled = false
		
		entities_inside.append(target)
	
	elif Globals.is_valid_entity(area, ["Player"]):
		
		for entity in entities_inside:
			if not is_instance_valid(entity) : continue
			
			entity.enabled = true
		
		await get_tree().create_timer(0.5, true).timeout
		
		for entity in entities_inside:
			if not is_instance_valid(entity) : continue
			
			entity.basic_on_active()
		
		entities_inside.clear()
