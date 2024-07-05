extends Control

@onready var fps = %fps
@onready var test = %test
@onready var test2 = %test2
@onready var test3 = %test3
@onready var test4 = %test4

var debugToggle = false
var toggle_debug_mode = false
var toggle_debug_magic_projectiles = false


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("show_debugInfo"):
		if not debugToggle:
			debugToggle = true
			visible = true
			
			get_tree().set_debug_collisions_hint(true)
			refresh_debugInfo()
			refresh_debugInfo_values()
			
			$/root/World.player.block_movement = true
		
		else:
			debugToggle = false
			visible = false
			
			get_tree().set_debug_collisions_hint(false) 
			
			$/root/World.player.block_movement = false
		
		
		if Input.is_action_pressed("move_UP"):
			Globals.debug_mode = true
			
			Globals.infoSign_current_text = str("Debug mode has been activated!")
			Globals.infoSign_current_size = 0
			Globals.info_sign_touched.emit()
			
		if Input.is_action_pressed("move_DOWN"):
			Globals.debug_mode = false
			
			Globals.infoSign_current_text = str("Debug mode has been disabled :(")
			Globals.infoSign_current_size = 0
			Globals.info_sign_touched.emit()


func refresh_debugInfo():
	fps.text = str("fps: ", Engine.get_frames_per_second())
	test.text = str("Total persistent objects present: ", Globals.test)
	test2.text = str("Total collectibles: ", Globals.test2)
	test3.text = str("Current level's area_ID: ", Globals.test3)
	test4.text = str("Debug value message: ", Globals.test4)


func refresh_debugInfo_values():
	Globals.test = get_tree().get_nodes_in_group("Persist").size() + get_tree().get_nodes_in_group("bonusBox").size()
	Globals.test2 =  get_tree().get_nodes_in_group("Collectibles").size()
	Globals.test3 = $/root/World.area_ID
	Globals.test4 = "unused debug value"




func set_night():
	$/root/World.get_node("%tileset_main").tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night.png")
	$/root/World.get_node("%tileset_main").tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 0.8


func set_night2():
	$/root/World.get_node("%tileset_main").tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night2.png")
	$/root/World.get_node("%tileset_main").tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night2.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 0.8


func set_night3():
	$/root/World.get_node("%tileset_main").tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset_night3.png")
	$/root/World.get_node("%tileset_main").tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations_night3.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 0.8
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 0.8



func set_day():
	$/root/World.get_node("%tileset_main").tile_set.get_source(0).texture = preload("res://Assets/Graphics/tilesets/tileset.png")
	$/root/World.get_node("%tileset_main").tile_set.get_source(3).texture = preload("res://Assets/Graphics/tilesets/tileset_decorations.png")
	for object in get_tree().get_nodes_in_group("Persist"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("player"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("button_block"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("button"):
		object.modulate.r = 1.0
	for object in get_tree().get_nodes_in_group("bonusBox"):
		object.modulate.r = 1.0




func night_modifications():
	await get_tree().create_timer(0.1, false).timeout
	
	if $/root/World.night3 or $/root/World.night2 or $/root/World.night:
		for object in get_tree().get_nodes_in_group("Persist"):
			object.modulate.r = 0.8
		for object in get_tree().get_nodes_in_group("player"):
			object.modulate.r = 0.8
		for object in get_tree().get_nodes_in_group("button_block"):
			object.modulate.r = 0.8
		for object in get_tree().get_nodes_in_group("button"):
			object.modulate.r = 0.8
		for object in get_tree().get_nodes_in_group("bonusBox"):
			object.modulate.r = 0.8
		
		
		$/root/World/ParallaxBackgroundGradient/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.modulate.r = 0.1
		$/root/World/ParallaxBackgroundGradient/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.modulate.a = 0.2
		
		
	else:
		for object in get_tree().get_nodes_in_group("Persist"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("player"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("button_block"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("button"):
			object.modulate.r = 1.0
		for object in get_tree().get_nodes_in_group("bonusBox"):
			object.modulate.r = 1.0




#BUTTONS

func _on_delete_all_save_files_pressed():
	DirAccess.remove_absolute("user://savegame_theBeginning.save")
	DirAccess.remove_absolute("user://savegame_Overworld.save")
	DirAccess.remove_absolute("user://savedProgress.save")
	DirAccess.remove_absolute("user://savegame.save")
	
	Globals.infoSign_current_text = str("All save files have been deleted.")
	Globals.infoSign_current_size = 1
	Globals.info_sign_touched.emit()


func _on_set_night_pressed():
	set_night()
	night_modifications()
	
	Globals.infoSign_current_text = str("Goodnight.")
	Globals.infoSign_current_size = 0
	Globals.info_sign_touched.emit()

func _on_set_night2_pressed():
	set_night2()
	night_modifications()
	
	Globals.infoSign_current_text = str("Goodnight... 2")
	Globals.infoSign_current_size = 0
	Globals.info_sign_touched.emit()

func _on_set_night3_pressed():
	set_night3()
	night_modifications()
	
	Globals.infoSign_current_text = str("It's mighty nightly in here...!")
	Globals.infoSign_current_size = 0
	Globals.info_sign_touched.emit()


func _on_delete_background_layers_pressed():
	if not $/root/World.debug_bg_deleted:
		$/root/World.debug_bg_deleted = true
		$/root/World.get_node("%bg_current").queue_free()
		$/root/World.get_node("%bg_previous").queue_free()
		
		Globals.infoSign_current_text = str("All background layers have been removed. (for better performance)")
		Globals.infoSign_current_size = 1
		Globals.info_sign_touched.emit()
		
	else:
		Globals.infoSign_current_text = str("Background layers have already been removed, silly!")
		Globals.infoSign_current_size = 1
		Globals.info_sign_touched.emit()


func _on_weapon_basic_pressed():
	$/root/World.player.weaponType = "basic"
func _on_weapon_veryFast_speed_pressed():
	$/root/World.player.weaponType = "veryFast_speed"
func _on_weapon_ice_pressed():
	$/root/World.player.weaponType = "ice"
func _on_weapon_fire_pressed():
	$/root/World.player.weaponType = "fire"
func _on_weapon_destructive_fast_speed_pressed():
	$/root/World.player.weaponType = "destructive_fast_speed"
func _on_weapon_short_shotDelay_pressed():
	$/root/World.player.weaponType = "short_shotDelay"
func _on_weapon_phaser_pressed():
	$/root/World.player.weaponType = "phaser"
func _on_secondaryWeapon_basic_pressed():
	$/root/World.player.secondaryWeaponType = "basic"
func _on_secondaryWeapon_fast_pressed():
	$/root/World.player.secondaryWeaponType = "fast"


func _on_reset_currently_selected_inventory_item_pressed():
	Globals.inventory_selectedItem = 1


func _on_set_short_shot_delay_pressed():
	$/root/World.player.get_node("%attack_cooldown").wait_time = 0.2
	$/root/World.player.get_node("%secondaryAttack_cooldown").wait_time = 0.2


func _on_set_long_shot_delay_pressed():
	$/root/World.player.get_node("%attack_cooldown").wait_time = 1
	$/root/World.player.get_node("%secondaryAttack_cooldown").wait_time = 1


func _on_toggle_debug_mode_pressed():
	if not toggle_debug_mode:
		toggle_debug_mode = true
		
		Globals.debug_mode = true
		
		Globals.infoSign_current_text = str("Debug mode has been activated!")
		Globals.infoSign_current_size = 0
		Globals.info_sign_touched.emit()
		
	else:
		toggle_debug_mode = false
		
		Globals.debug_mode = false
		
		Globals.infoSign_current_text = str("Debug mode has been disabled :(")
		Globals.infoSign_current_size = 0
		Globals.info_sign_touched.emit()


func _on_set_immortal_pressed():
	Globals.playerHP = 99999
	
	#$Player_hitbox_main.monitoring = false
	#$Player_hitbox_exact.monitoring = false
	#$Player_hitbox_main.monitorable = false
	#$Player_hitbox_exact.monitorable = false

func _on_toggle_magic_projectiles_pressed():
	if not toggle_debug_magic_projectiles:
		toggle_debug_magic_projectiles = true
		
		Globals.debug_magic_projectiles = true
		
		Globals.infoSign_current_text = str("Magic projectiles have been activated! Now they will respawn at player position instead of being removed. If you end up with too many at once, just toggle this option again.")
		Globals.infoSign_current_size = 3
		Globals.info_sign_touched.emit()
		
	else:
		toggle_debug_magic_projectiles = false
		
		Globals.debug_magic_projectiles = false
		
		Globals.infoSign_current_text = str("Magic projectiles are no more...")
		Globals.infoSign_current_size = 0
		Globals.info_sign_touched.emit()
