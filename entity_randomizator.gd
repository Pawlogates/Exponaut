extends Node2D

@onready var entity : Node = get_parent()


var list_behavior_name : Array = []
var d_properties_all : Dictionary


func _ready():
	await get_tree().create_timer(1, true).timeout
	entity = get_parent()
	
	entity.sprite.sprite_frames = load(Globals.l_sprite_entity.pick_random())
	
	var script : GDScript = entity.get_script()
	
	for property_info in script.get_script_property_list():
		if property_info.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property_info.usage & PROPERTY_USAGE_STORAGE > 0:
			var property_name = property_info.name
			var property_value = entity.get(property_name)
			
			if property_name == "entity" : continue
			
			d_properties_all.get_or_add(property_name, property_value)
			
			
			if entity.get(property_name) is bool:
				entity.set(property_name, Globals.random_bool(1, 5))
			
			elif entity.get(property_name) is float or entity.get(property_name) is int:
				if "cooldown" in property_name:
					entity.set(property_name, randf_range(6, 24))
				else:
					if abs(entity.get(property_name)) > 50:
						entity.set(property_name, randf_range(4 * property_value, 4 * property_value))
					else:
						randf_range(6, 24)
					
					if property_value >= 0: # Before it was changed.
						if Globals.random_bool(5, 1):
							entity.set(property_name, abs(entity.get(property_name)))
					else:
						if entity.get(property_name) > 0: # After it was changed.
							entity.set(property_name, -entity.get(property_name))
			
			
			elif entity.get(property_name) is String:
				if "filepath" in property_name:
					if Globals.random_bool(1, 9):
						entity.set(property_name, Globals.l_entity.pick_random())
					else:
						entity.set(property_name, "res://Enemies/entity_randomized.tscn")
			
			elif entity.get(property_name) is Array:
				if entity.get(property_name)[0] is int or entity.get(property_name)[0] is float:
					for x in entity.get(property_name):
						if x is int or x is float:
							if abs(x) > 10:
								x = randf_range(-200, 1200)
				
				elif entity.get(property_name)[0] is String:
					if property_name == "movement_type":
						entity.set(property_name, Globals.l_entity_movement_limited.pick_random())
			
			if property_name == "limit_spawn_entity_cooldown":
				entity.set(property_name, Globals.random_bool(1, 23))
			
			if "can_move" in property_name:
				entity.set(property_name, true)
			
			if property_name == "breakable_advanced_portal_on_death_open":
				entity.set(property_name, Globals.random_bool(23, 1))
	
	SaveData.save_file(Globals.dirpath_saves + "/" + "properties.json", d_properties_all, true)
