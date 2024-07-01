extends CharacterBody2D


var starParticleScene = preload("res://particles_special.tscn")
var starParticle2Scene = preload("res://particles_star.tscn")
var orbParticleScene = preload("res://particles_special2_multiple.tscn")
#var starParticle = starParticleScene.instantiate()
#var starParticle2 = starParticle2Scene.instantiate()
#var orbParticle = orbParticleScene.instantiate()

var hit_effectScene = preload("res://hit_effect.tscn")

var splashParticleScene = preload("res://particles_water_entered.tscn")
#var splashParticle = splashParticleScene.instantiate()

var effect_dustScene = preload("res://effect_dust.tscn")
#var effect_dust = effect_dustScene.instantiate()

var feathersParticleScene = preload("res://particles_feathers.tscn")
#var feathersParticle = feathersParticleScene.instantiate()

var start_pos = global_position

var collected = false
var removable = false
var rotten = false

var playerProjectile = true
var enemyProjectile = true

var button_pressed = false
var stop_upDownLoopAnim = false

var collected_special = false

var checkpoint_active = false

@onready var collect_1 = %collect1
@onready var timer = %Timer
@onready var animation_player = %AnimationPlayer
@onready var animation_player_2 = %AnimationPlayer2
@onready var sprite = %AnimatedSprite2D

#PROPERTIES
@export var collectibleScoreValue = 50
@export var hard_to_collect = false
@export var is_gift = false
@export var animation_always = false
@export var floating = false
@export var is_key = false
@export var collectable = true
@export var upDown_loop = false
@export var hp = 5
@export var is_shrineGem = false
@export var shrineGem_destructible = false
@export var shrineGem_giveScore = false
@export var shrineGem_spawnItems = false
@export var shrineGem_openPortal = false
@export var shrineGem_particleAmount = 25
@export var shrineGem_portal_level_ID = "none"
@export var shrineGem_portal_level_number = 0
@export_file("*.tscn") var shrineGem_level_filePath : String
@export var shrineGem_displayedName = "none"
@export var shrineGem_is_finalLevel = false

@export var is_specialApple = "none" #options: "red", "blue", "golden"

@export_file("*.tscn") var item_scene = "res://Collectibles/Gift_orangeBox.tscn" #preload("res://Collectibles/collectibleApple.tscn")
@export var spawnedAmount = 3
@export var item_posSpread = 100
@export var item_velSpread = 300

#WEAPON PICKUP
@export var is_weapon = false
@export var is_SecondaryWeapon = false

@export var weapon_type = "none"
@export var attack_delay = 1.0
@export var secondaryWeapon_type = "none"
@export var secondaryAttack_delay = 1.0
#WEAPON PICKUP

@export var is_healthItem = false
@export var rotting = false
@export var fall_when_button_pressed = false

@export var is_potion = false
@export var transform_into = "none"



@onready var topRankScore = 100000

@onready var level_completionState = 0
@onready var level_score = 0
@onready var level_rank = "D"
@onready var level_rank_value = 1

#OFFSCREEN START

func _ready():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	animation_player_2.active = false
	$Area2D.set_monitorable(false)
	
	#OFFSCREEN END
	
	animation_player.advance(abs(start_pos[0]) / 100)
	Globals.saveState_loaded.connect(saveState_loaded)
	
	if upDown_loop:
		animation_player.play("loop")
	
	if rotting:
		%rotDelay.start()
	
	if shrineGem_is_finalLevel:
		modulate.g = 0.0
		modulate.b = 0.0
	
	
	
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.monitoring = true
	
	if global_position != Vector2(0, 0):
		start_pos = global_position
	
	if shrineGem_openPortal:
		level_completionState = LevelTransition.get_node("%saved_progress").get("state_" + shrineGem_portal_level_ID)
		level_score = LevelTransition.get_node("%saved_progress").get("score_" + shrineGem_portal_level_ID)
	
		if Globals.selected_episode == "Additional Levels":
			if shrineGem_portal_level_number == 1:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 2:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 3:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 4:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 5:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 6:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 7:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 8:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 9:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 10:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 11:
				topRankScore = 50000
		
		elif Globals.selected_episode == "Main Levels":
			if shrineGem_portal_level_number == 1:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 2:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 3:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 4:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 5:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 6:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 7:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 8:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 9:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 10:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 11:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 12:
				topRankScore = 50000
			elif shrineGem_portal_level_number == 13:
				topRankScore = 50000
		
		var rating_top = topRankScore
		var rating_6 = rating_top * 0.8
		var rating_5 = rating_top * 0.6
		var rating_4 = rating_top * 0.4
		var rating_3 = rating_top * 0.2
		var rating_2 = rating_top * 0.1
		var rating_1 = 0
		
		if level_score >= rating_top:
			level_rank = "S+"
			level_rank_value = 7
		elif level_score >= rating_6:
			level_rank = "S"
			level_rank_value = 6
		elif level_score >= rating_5:
			level_rank = "A"
			level_rank_value = 5
		elif level_score >= rating_4:
			level_rank = "B"
			level_rank_value = 4
		elif level_score >= rating_3:
			level_rank = "C"
			level_rank_value = 3
		elif level_score >= rating_2:
			level_rank = "D"
			level_rank_value = 2
		elif level_score >= rating_1:
			level_rank = "none"
			level_rank_value = 1
	
	await get_tree().create_timer(5, false).timeout
	checkpoint_active = true




func saveState_loaded():
	animation_player.advance(abs(start_pos[0]) / 100)
	




#IS IN VISIBLE RANGE?

func offScreen_unload():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	animation_player_2.active = false
	$Area2D.set_monitorable(false)
	
	
	

func offScreen_load():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	sprite.play()
	sprite.visible = true
	animation_player.active = true
	animation_player_2.active = true
	$Area2D.set_monitorable(true)
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if removable or collected and not animation_player_2.current_animation == "score_value" and not animation_player.current_animation == "remove":
		print("Removed already collected entity.")
		queue_free()
	
	


var bonus_material = preload("res://Collectibles/bonus_material.tres")

@export var inventory_item_scene = preload("res://inventoryItem.tscn")
@export var inventory_itemToSpawn = preload("res://Collectibles/collectibleApple.tscn")
@export var inventory_texture_region = Rect2(0, 0, 0, 0)


func _on_collectible_entered(body):
	inside_check_enter(body)
	
	if is_specialApple != "none":
		if is_specialApple == "golden":
			Globals.collected_goldenApples += 1
			%collectedDisplay.text = str(Globals.collected_goldenApples)
		
		elif is_specialApple == "blue":
			Globals.collected_blueApples += 1
			%collectedDisplay.text = str(Globals.collected_blueApples)
		
		elif is_specialApple == "red":
			Globals.collected_redApples += 1
			%collectedDisplay.text = str(Globals.collected_redApples)
			
		
		
		$Area2D.set_deferred("monitoring", false)
		%AnimationPlayer.play("collect_special")
		animation_player_2.play("score_value")
		random_pitch_collect()
		collected_special = true
		
		return
	
	
	if is_healthItem:
		if body.is_in_group("player") and not collected:
			collected = true
			Globals.itemCollected.emit()
			Globals.increaseHp1.emit()
			
			animation_player.play("remove")
			collect_1.play()
			body.add_child(starParticleScene.instantiate())
			body.add_child(starParticleScene.instantiate())
			body.add_child(starParticleScene.instantiate())
			body.add_child(starParticleScene.instantiate())
			
			var feathersParticle = feathersParticleScene.instantiate()
			feathersParticle.position = position
			$/root/World.add_child(feathersParticle)
			
			feathersParticle = feathersParticleScene.instantiate()
			feathersParticle.position = position
			$/root/World.add_child(feathersParticle)
			
			return
			
		
	
	if is_gift and get_tree().get_nodes_in_group("in_inventory").size() >= 6:
		return
	
	if is_gift and body.is_in_group("player") and not collected or is_gift and body.is_in_group("player_projectile") and body.can_collect and not collected:
		if get_tree().get_nodes_in_group("in_inventory").size() < 6:
			var item = inventory_item_scene.instantiate()
			$/root/World.get_node("HUD/Inventory/InventoryContainer").add_child(item)
			item.item_toSpawn = inventory_itemToSpawn
			item.display_region_rect = inventory_texture_region
		
		$/root/World.get_node("HUD/Inventory").call("check_inventory")
		get_tree().call_group("in_inventory", "selected_check")
		
		#get_tree().call_group("in_inventory", "itemOrder_correct")
	
	
	if is_shrineGem:
		if body.is_in_group("player"):
			%AnimatedSprite2D.modulate.r = 0.3
			%AnimatedSprite2D.modulate.a = 0.5
			
		elif body.is_in_group("player_projectile") and not collected:
			if not body.upward_attack:
				velocity.y = -200
				velocity.x = 400 * body.direction
			else:
				velocity.y = -600
				
			stop_upDownLoopAnim = true
			floating = false
			%hit1.play()
			%AnimationPlayer2.stop()
			if not shrineGem_is_finalLevel:
				%AnimationPlayer2.play("hit")
			else:
				%AnimationPlayer2.play("hit_finalLevel")
			
			var starParticle = starParticleScene.instantiate()
			starParticle.position = position
			$/root/World.add_child(starParticle)
			
			add_child(splashParticleScene.instantiate())
		
			if shrineGem_destructible:
				hp -= 1
				if hp <= 0 and not collected:
					collected = true
					stop_upDownLoopAnim = false
					
					add_child(hit_effectScene.instantiate())
					add_child(orbParticleScene.instantiate())
					add_child(splashParticleScene.instantiate())
					add_child(effect_dustScene.instantiate())
					
					#await get_tree().create_timer(0.5, false).timeout
					
					%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
					
					#timer.start()
					animation_player.play("remove")
					animation_player_2.play("score_value")
					
					
					if Globals.collected_in_cycle == 0:
						Globals.level_score += collectibleScoreValue
					
					else:
						Globals.level_score += collectibleScoreValue
						Globals.combo_score += collectibleScoreValue * Globals.combo_tier
					
					Globals.itemCollected.emit()
					
					if shrineGem_giveScore:
						give_score()
						
					if shrineGem_spawnItems:
						call_deferred("spawn_collectibles")
						Globals.boxBroken.emit()
					
					if shrineGem_openPortal:
						call_deferred("spawn_portal")
					
					if shrineGem_portal_level_ID != "none" and LevelTransition.get_node("%saved_progress").get("state_" + str(shrineGem_portal_level_ID)) == 0:
						LevelTransition.get_node("%saved_progress").set(("state_" + str(shrineGem_portal_level_ID)), -1)
						Globals.save_progress.emit()
						
	
	
	if collectable and not rotten and body.is_in_group("player") and not collected or collectable and not rotten and body.is_in_group("player_projectile") and body.can_collect and not collected:
		collected = true
		%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
		
		#timer.start()
		animation_player.play("remove")
		animation_player_2.play("score_value")
		
		
		if Globals.collected_in_cycle == 0:
			Globals.level_score += collectibleScoreValue
		
		else:
			Globals.level_score += collectibleScoreValue
			Globals.combo_score += collectibleScoreValue * Globals.combo_tier
		
		Globals.itemCollected.emit()
		
		give_score()
		
		if is_potion:
			$/root/World.reassign_player()
			
			if transform_into == "rooster":
				$/root/World.player.transformInto_rooster()
			elif transform_into == "bird":
				$/root/World.player.transformInto_bird()
			elif transform_into == "chicken":
				$/root/World.player.transformInto_chicken()
			elif transform_into == "frog":
				$/root/World.player.transformInto_frog()
			elif transform_into == "pig":
				$/root/World.player.transformInto_pig()
			
			$/root/World.reassign_player()
		
		
		if is_key:
			$/root/World.key_collected()
			
			add_child(orbParticleScene.instantiate())
			
		
		if is_weapon:
			$/root/World.reassign_player()
			$/root/World.player.weaponType = weapon_type
			$/root/World.player.get_node("%attack_cooldown").wait_time = attack_delay
			
			add_child(orbParticleScene.instantiate())
			add_child(splashParticleScene.instantiate())
			add_child(effect_dustScene.instantiate())
			
			Globals.weapon_collected.emit()
		
		if is_SecondaryWeapon:
			$/root/World.reassign_player()
			$/root/World.player.secondaryWeaponType = secondaryWeapon_type
			$/root/World.player.get_node("%secondaryAttack_cooldown").wait_time = secondaryAttack_delay
			
			add_child(orbParticleScene.instantiate())
			add_child(splashParticleScene.instantiate())
			add_child(effect_dustScene.instantiate())
			
			Globals.secondaryWeapon_collected.emit()




func _on_collectible_exited(body):
	inside_check_exit(body)
	
	if is_shrineGem:
		if body.is_in_group("player"):
			%AnimatedSprite2D.modulate.r = 1.0
			%AnimatedSprite2D.modulate.a = 1.0
			
		elif body.is_in_group("player_projectile"):
			pass



func _on_timer_timeout():
	print("Collectible removed on timeout. (?)")
	queue_free()


func _on_animation_player_2_animation_finished(anim_name):
	if anim_name != "hit" and not collected_special:
		removable = true






var velocity_x_last = 0.0
var direction_last = 0.0

@export var direction = 0
@export var SPEED = 600.0
@export var SLOWDOWN = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var random_position_offset = Vector2(randf_range(0, 250), randf_range(0, 250)) 

func _physics_process(delta):
	if collected_special:
		position = lerp(position, $/root/World.player.position + random_position_offset, delta)
	
	
	if stop_upDownLoopAnim:
		stop_upDownLoop()
	
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	
	
	if direction:
		velocity.x = direction * SPEED
	elif collidable or is_shrineGem:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED / SLOWDOWN * delta)
		
		
		
	if player_inside:
		#if hard_to_collect or rotten:
		collidable = false
		$collisionCheck_delay.start()
		
		if Globals.direction != 0:
			direction_last = Globals.direction
			
		velocity.x = SPEED * direction_last
	
	
	if enemy_inside:
		if collidable:
			collidable = false
			$collisionCheck_delay.start()
			
			if direction != 0:
				direction_last = direction
			velocity.x = 250 * direction_last
		
		
	
	if is_on_wall():
		velocity.x = -velocity_x_last / 2
		collidable = false
		$collisionCheck_delay.start()
		
	elif velocity.x != 0:
		velocity_x_last = velocity.x
		
	
	if not collected and not floating and not collected_special or button_pressed:
		move_and_slide()
	
	
	
	if not animation_always:
		%AnimatedSprite2D.speed_scale = velocity.x / 100
	
	
	
	
	
	if fall_when_button_pressed:
		if button_pressed and %AnimatedSprite2D.position.y > 0:
			%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
			%AnimatedSprite2D.position.y -= 1

			
		elif button_pressed and %AnimatedSprite2D.position.y < 0:
			%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
			%AnimatedSprite2D.position.y += 1
	
	if debug:
		print(item_scene)

@export var debug = false











func _on_collision_check_delay_timeout():
	collidable = true



func destroy_self():
	print("This entity (type: collectible) has self destroyed.")
	queue_free()



func on_button_press():
	if not collected:
		velocity.y = 0
		button_pressed = true
		animation_player.pause()



func _on_rot_delay_timeout():
	rotten = true
	%AnimatedSprite2D.material = preload("res://Collectibles/rotten_material.tres")




var player_inside = false
var enemy_inside = false
var player_projectile_inside = false

var collidable = true



func inside_check_enter(body):
	if body.is_in_group("player"):
		player_inside = true
		print("entered player")
		if collidable and hard_to_collect or collidable and rotten:
			collidable = false
			$collisionCheck_delay.start()
			
			direction = body.direction
		
	if body.is_in_group("enemies"):
		enemy_inside = true
		if collidable:
			collidable = false
			$collisionCheck_delay.start()
			
			direction = body.direction
		
	if body.is_in_group("player_projectile"):
		player_projectile_inside = true
		if collidable:
			collidable = false
			$collisionCheck_delay.start()
			
			direction = body.direction
			



func inside_check_exit(body):
	if body.is_in_group("player") or body.is_in_group("player_projectile") or body.is_in_group("enemies"):
		
		if body.is_in_group("player"):
			#if hard_to_collect or rotten:
			player_inside = false
			direction = body.direction
			print("exitted player")
		
		if body.is_in_group("player_projectile"):
			player_projectile_inside = false
			direction = body.direction
		
		if body.is_in_group("enemies"):
			enemy_inside = false
			direction = body.direction
		
		
		
		
		if not player_inside and not player_projectile_inside and not enemy_inside:
			direction = 0
		







#func _on_area_2d_area_entered(area):
	##SAVE START
	#
	#if area.is_in_group("loadingZone_area"):
	#
		#remove_from_group("loadingZone0")
		#remove_from_group("loadingZone1")
		#remove_from_group("loadingZone2")
		#remove_from_group("loadingZone3")
		#remove_from_group("loadingZone4")
		#remove_from_group("loadingZone5")
		#
		#loadingZone = area.loadingZone_number
		#add_to_group(loadingZone)
		#
		##print("this ", name, " is in: ", loadingZone, is_in_group(loadingZone))
	#
	#
	##SAVE END



func stop_upDownLoop():
	animation_player.pause()
	if %AnimatedSprite2D.position.y > 0:
		%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
		%AnimatedSprite2D.position.y -= 1
		
	elif %AnimatedSprite2D.position.y < 0:
		%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
		%AnimatedSprite2D.position.y += 1


func give_score():
	add_child(starParticleScene.instantiate())
	if Globals.combo_tier > 1:
		add_child(starParticleScene.instantiate())
		%collect1.pitch_scale = 1.1
		if Globals.combo_tier > 2:
			add_child(starParticleScene.instantiate())
			%collect1.pitch_scale = 1.2
			if Globals.combo_tier > 3:
				add_child(starParticleScene.instantiate())
				%collect1.pitch_scale = 1.3
				if Globals.combo_tier > 4:
					add_child(starParticle2Scene.instantiate())
					%collect1.pitch_scale = 1.4
					bonus_material.set_shader_parameter("strength", 0.5)
					
	else:
		%collect1.pitch_scale = 1
		bonus_material.set_shader_parameter("strength", 0.0)
			
	collect_1.play()





func spawn_collectibles():
	while spawnedAmount > 0:
		spawnedAmount -= 1
		spawn_item()
		
	
	var hit_effect = hit_effectScene.instantiate()
	add_child(hit_effect)




var rng = RandomNumberGenerator.new()

func spawn_item():
	var item = load(item_scene).instantiate()
	if "velocity" in item:
		item.position = global_position
		item.velocity.x = rng.randf_range(item_velSpread, -item_velSpread)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
		
		$/root/World.add_child(item)
	else:
		spawn_item_static()


func spawn_item_static():
	var item = load(item_scene).instantiate()
	item.position.x = global_position.x + rng.randf_range(item_posSpread, -item_posSpread)
	item.position.y = global_position.y + rng.randf_range(item_posSpread, -item_posSpread)
	
	$/root/World.add_child(item)



func spawn_portal():
	var portal = preload("res://shrine_portal.tscn").instantiate()
	portal.level_ID = shrineGem_portal_level_ID
	portal.level_number = shrineGem_portal_level_number
	portal.target_area = shrineGem_level_filePath
	portal.particle_amount = shrineGem_particleAmount
	portal.position = start_pos
	
	portal.level_completionState = level_completionState
	portal.level_score = level_score
	portal.level_rank = level_rank
	portal.level_rank_value = level_rank_value
	portal.level_displayedName = shrineGem_displayedName
	
	$/root/World.add_child(portal)





func _on_animation_player_animation_finished(anim_name):
	if anim_name == "collect_special":
		print("Special collectible has been deleted after the collect animation finished.")
		queue_free()


func random_pitch_collect():
	collect_1.pitch_scale = (randf_range(0.8, 1.2))
	collect_1.play()


func _on_shrine_gem_checkpoint_trigger_body_entered(body):
	if checkpoint_active:
		if body.is_in_group("player"):
			#await get_tree().create_timer(1, false).timeout
			print("Shrine Gem checkpoint activated.")
			checkpoint_active = false
			$/root/World.save_game()
			$/root/World.save_game_area()
			SavedData.savedData_save(true)









#SAVE START

#var loadingZone = "loadingZone0"

func save():
	var save_dict = {
		#"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"collected" : collected,
		"hp" : hp,
		"shrineGem_portal_level_ID" : shrineGem_portal_level_ID,
		"shrineGem_level_filePath" : shrineGem_level_filePath,
		"collected_special" : collected_special,
		"is_shrineGem" : is_shrineGem,
		"shrineGem_destructible" : shrineGem_destructible,
		"shrineGem_giveScore" : shrineGem_giveScore,
		"shrineGem_spawnItems" : shrineGem_spawnItems,
		"shrineGem_openPortal" : shrineGem_openPortal,
		"shrineGem_particleAmount" : shrineGem_particleAmount,
		"shrineGem_portal_level_number" : shrineGem_portal_level_number,
		"shrineGem_displayedName" : shrineGem_displayedName,
		"shrineGem_is_finalLevel" : shrineGem_is_finalLevel,
		"is_specialApple" : is_specialApple,
		"item_scene" : item_scene,
		"spawnedAmount" : spawnedAmount,
		"item_posSpread" : item_posSpread,
		"item_velSpread" : item_velSpread,
		"floating" : floating,
		"debug" : debug,
		"stop_upDownLoopAnim" : stop_upDownLoopAnim,
		
	}
	return save_dict

#SAVE END
