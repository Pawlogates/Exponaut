extends Control

@onready var onSpawn_item_scene = Globals.inventory_onSpawn_scene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("inventory_right"):
		if Globals.inventory_selectedItem == get_tree().get_nodes_in_group("in_inventory").size():
			Globals.inventory_selectedItem = 1
		else:
			Globals.inventory_selectedItem += 1
		
		get_tree().call_group("in_inventory", "selected_check")
		
	elif Input.is_action_just_pressed("inventory_left"):
		if Globals.inventory_selectedItem == 1:
			Globals.inventory_selectedItem = get_tree().get_nodes_in_group("in_inventory").size()
		else:
			Globals.inventory_selectedItem -= 1
		
		get_tree().call_group("in_inventory", "selected_check")
	
	
	#$Label.text = str("selected item: ", Globals.inventory_selectedItem)
	#$Label2.text = str("path to item that will spawn: ", Globals.inventory_onSpawn_scene)
	
	
	
	
	
	if Input.is_action_just_pressed("use_item"):
		get_tree().call_group("in_inventory", "selected_check")
		
		if Globals.inventory_onSpawn_scene != null:
			
			spawn_selected()
			
			Globals.inventory_onSpawn_scene = null
			Globals.inventory_selectedItem = 1
			
			if get_tree().get_nodes_in_group("delete_on_itemUse").size() != 0:
				get_tree().call_group("delete_on_itemUse", "queue_free")
				
		
		
		await get_tree().create_timer(0.2, false).timeout
		check_inventory()





var inventory_opened = false
var ID_assign = 0

func check_inventory():
	if not inventory_opened and get_tree().get_nodes_in_group("in_inventory").size() == 1:
		inventory_opened = true
		$AnimationPlayer.play("show")
			
	elif inventory_opened and get_tree().get_nodes_in_group("in_inventory").size() == 0:
		inventory_opened = false
		$AnimationPlayer.play("hide")
	
	
	for node in get_tree().get_nodes_in_group("in_inventory"):
		ID_assign += 1
		node.inventory_itemID = ID_assign
		
		if ID_assign >= get_tree().get_nodes_in_group("in_inventory").size():
			ID_assign = 0 





func spawn_selected():
	if get_tree().get_nodes_in_group("delete_on_itemUse").size() != 0:
		onSpawn_item_scene = Globals.inventory_onSpawn_scene
		var onSpawn_item = onSpawn_item_scene.instantiate()
		get_parent().get_parent().add_child(onSpawn_item)
		onSpawn_item.position = Globals.player_pos
