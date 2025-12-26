extends Control

var itemDisplay_scene = preload("res://Other/Scenes/User Interface/Quick Select/quickselect_itemDisplay.tscn")
var previous_state = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.World.level_type != "overworld":
		queue_free()
	
	Globals.weapon_collected.connect(show_weapon)
	Globals.secondaryWeapon_collected.connect(show_secondaryWeapon)
	
	load_saved_unlocked_weapons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("state:" + str(unlock_state_secondaryWeapon_basic))
	if Input.is_action_pressed("quickselect"):
		Globals.Player.block_movement = true
		position.y = lerp(position.y, 345.0, 5 * delta)
		scale = lerp(scale, Vector2(1.0, 1.0), 5 * delta)
	
	else:
		Globals.Player.block_movement = false
		position.y = lerp(position.y, 2000.0, delta)
		scale = lerp(scale, Vector2(0.01, 0.01), 10 * delta)


func load_saved_unlocked_weapons():
	if SaveData.saved_weapon_basic >= 0:
		place_item_display("weapon_basic", 0)
		
	if SaveData.saved_weapon_short_shotDelay >= 0:
		place_item_display("weapon_short_shotDelay", 0)
		
	if SaveData.saved_weapon_ice >= 0:
		place_item_display("weapon_ice", 0)
	
	if SaveData.saved_weapon_fire >= 0:
		place_item_display("weapon_fire", 0)
	
	if SaveData.saved_weapon_destructive_fast_speed >= 0:
		place_item_display("weapon_destructive_fast_speed", 0)
	
	if SaveData.saved_weapon_veryFast_speed >= 0:
		place_item_display("weapon_veryFast_speed", 0)
	
	if SaveData.saved_weapon_phaser >= 0:
		place_item_display("weapon_phaser", 0)
	
	#secondary weapon types
	if SaveData.saved_secondaryWeapon_basic >= 0:
		place_item_display("secondaryWeapon_basic", 1)
	
	if SaveData.saved_secondaryWeapon_fast >= 0:
		place_item_display("secondaryWeapon_fast", 1)


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
	
	else:
		return
	
	
	var allowed = true
	for checked_itemDisplay in get_tree().get_nodes_in_group("quickselect_itemDisplay"):
		if checked_itemDisplay.item == itemDisplay.item:
			allowed = false
			#checked_itemDisplay.queue_free()
	
	if allowed:
		var item = itemDisplay.item
		%quickselect_items.add_child(itemDisplay)
		previous_state = get("unlock_state_" + item)
		if previous_state < 0:
			set("unlock_state_" + item, 0)
		
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
		var item = itemDisplay.item
		%quickselect_items.add_child(itemDisplay)
		previous_state = get("unlock_state_" + item)
		if previous_state < 0:
			set("unlock_state_" + item, 0)
		
		
	get_tree().get_first_node_in_group("quickselect_itemDisplay").get_node("%Button").grab_focus()
	


#item unlock states [-1 if locked, 0 if available for purchase (found once), 1 if unlocked]
var unlock_state_weapon_basic = -1
var unlock_state_weapon_veryFast_speed = -1
var unlock_state_weapon_ice = -1
var unlock_state_weapon_fire = -1
var unlock_state_weapon_destructive_fast_speed = -1
var unlock_state_weapon_short_shotDelay = -1
var unlock_state_weapon_phaser = -1
var unlock_state_secondaryWeapon_basic = -1
var unlock_state_secondaryWeapon_fast = -1

func place_item_display(item, weaponMode):
	var itemDisplay = itemDisplay_scene.instantiate()
	
	itemDisplay.item = item
	itemDisplay.weaponMode = weaponMode
	
	var allowed = true
	for checked_itemDisplay in get_tree().get_nodes_in_group("quickselect_itemDisplay"):
		if checked_itemDisplay.item == itemDisplay.item:
			allowed = false
			#checked_itemDisplay.queue_free()
	
	if allowed:
		item = itemDisplay.item
		if SaveData.get("saved_" + item) == 1:
			itemDisplay.unlocked = true
			set("unlock_state_" + item, 1)
			
		%quickselect_items.add_child(itemDisplay)
		
		previous_state = get("unlock_state_" + item)
		if previous_state < 0:
			set("unlock_state_" + item, 0)
		
		
	get_tree().get_first_node_in_group("quickselect_itemDisplay").get_node("%Button").grab_focus()

func reassign_player():
	Globals.Player = get_tree().get_first_node_in_group("player_root")
