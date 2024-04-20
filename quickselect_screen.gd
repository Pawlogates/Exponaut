extends Control

var itemDisplay_scene = load("res://quickselect_itemDisplay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.weapon_collected.connect(show_weapon)
	Globals.secondaryWeapon_collected.connect(show_secondaryWeapon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("quickselect"):
		position.y = lerp(position.y, 345.0, 5 * delta)
		scale = lerp(scale, Vector2(1.0, 1.0), 5 * delta)
	
	else:
		position.y = lerp(position.y, 2000.0, delta)
		scale = lerp(scale, Vector2(0.01, 0.01), 10 * delta)


func show_weapon():
	var itemDisplay = itemDisplay_scene.instantiate()
	itemDisplay.weaponMode = 0
	
	if $/root/World.player.weaponType == "basic":
		itemDisplay.item = "weapon_basic"
		
	elif $/root/World.player.weaponType == "short_shotDelay":
		itemDisplay.item = "weapon_short_shotDelay"
		
	elif $/root/World.player.weaponType == "ice":
		itemDisplay.item = "weapon_ice"
	
	elif $/root/World.player.weaponType == "fire":
		itemDisplay.item = "weapon_fire"
	
	elif $/root/World.player.weaponType == "destructive_fast_speed":
		itemDisplay.item = "weapon_destructive_fast_speed"
	
	elif $/root/World.player.weaponType == "veryFast_speed":
		itemDisplay.item = "weapon_veryFast_speed"
	
	elif $/root/World.player.weaponType == "phaser":
		itemDisplay.item = "weapon_phaser"
	
	
	
	var allowed = true
	for checked_itemDisplay in get_tree().get_nodes_in_group("quickselect_itemDisplay"):
		if checked_itemDisplay.item == itemDisplay.item:
			allowed = false
			#checked_itemDisplay.queue_free()
	
	if allowed:
		%quickselect_items.add_child(itemDisplay)
		
	get_tree().get_first_node_in_group("quickselect_itemDisplay").get_node("%Button").grab_focus()
	

func show_secondaryWeapon():
	var itemDisplay = itemDisplay_scene.instantiate()
	itemDisplay.weaponMode = 1
	
	if $/root/World.player.secondaryWeaponType == "basic":
		itemDisplay.item = "secondaryWeapon_basic"
	
	if $/root/World.player.secondaryWeaponType == "fast":
		itemDisplay.item = "secondaryWeapon_fast"
	
	
	var allowed = true
	for checked_itemDisplay in get_tree().get_nodes_in_group("quickselect_itemDisplay"):
		if checked_itemDisplay.item == itemDisplay.item:
			allowed = false
			#checked_itemDisplay.queue_free()
	
	if allowed:
		%quickselect_items.add_child(itemDisplay)
		
	get_tree().get_first_node_in_group("quickselect_itemDisplay").get_node("%Button").grab_focus()
	
