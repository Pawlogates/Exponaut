extends Control

@onready var container_behavior_buttons = $container_behavior_buttons
@onready var bg: ColorRect = $bg


func _ready():
	Globals.weapon_blocked = true
	
	if Globals.weapon["apply_default"] or Globals.gameState_debug: # Apply default values if the entity has never been edited.
		for property_name in Globals.l_available_property_name:
			Globals.weapon.get_or_add(property_name, Globals.get("l_" + property_name + "_button_info")["behavior_value"])
			
			Globals.weapon["apply_default"] = false # From this point, the default property values ("l_property_name_button_info[behavior_value]") will not be applied every time the entity editor spawns.
	
	for property_name in Globals.weapon:
		if property_name == "none" : continue
		
		Globals.entity_editor_preview.set(property_name, Globals.weapon[property_name])
	
	for property_name in Globals.l_available_property_name:
		print(Globals.weapon_main_unlocks)
		if not Globals.get("weapon_main_unlocks")[property_name][0] : continue # Do not generate the property button if the property has not been unlocked.
		
		# Property of float or int value.
		if Globals.get("l_" + property_name + "_button_info")["behavior_available_options"] == ["none"]:
			
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_int_float).instantiate()
			
			behavior_button.type = "int_float"
			behavior_button.set("behavior_info", Globals.get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = Globals.l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)
		
		# Property of bool value (technically an Array containing "true" and "false").
		elif Globals.get("l_" + property_name + "_button_info")["behavior_available_options"] == [true, false]:
			var behavior_button = load(Globals.scene_entity_editor_behavior_button_bool).instantiate()
			
			behavior_button.type = "bool"
			behavior_button.set("behavior_info", Globals.get("l_" + property_name + "_button_info"))
			behavior_button.property_name = property_name
			behavior_button.property_number = Globals.l_available_property_name.find(property_name)
			
			container_behavior_buttons.add_child(behavior_button)
		
		# Property of Array value.
		else:
			if "range" in property_name:
				# Following code is exactly the same (excluding the type assignment) as the one under the assumption that the property is of numerical type ("int_float").
				var behavior_button = load(Globals.scene_entity_editor_behavior_button_int_float).instantiate()
				
				behavior_button.type = "Array_Vector2_range"
				behavior_button.set("behavior_info", Globals.get("l_" + property_name + "_button_info"))
				behavior_button.property_name = property_name
				behavior_button.property_number = Globals.l_available_property_name.find(property_name)
				
				container_behavior_buttons.add_child(behavior_button)
			
			else:
				var behavior_button = load(Globals.scene_entity_editor_behavior_button_Array).instantiate()
				
				behavior_button.type = "Array"
				behavior_button.set("behavior_info", Globals.get("l_" + property_name + "_button_info"))
				behavior_button.property_name = property_name
				behavior_button.property_number = Globals.l_available_property_name.find(property_name)
				
				container_behavior_buttons.add_child(behavior_button)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quickselect"):
		Globals.weapon_blocked = false
		queue_free()
