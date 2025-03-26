extends CharacterBody2D

var starParticleScene = preload("res://Particles/particles_special.tscn")
var starParticle2Scene = preload("res://Particles/particles_star.tscn")
var orbParticleScene = preload("res://Particles/particles_special2_multiple.tscn")
var hit_effectScene = preload("res://Particles/hit_effect.tscn")
var splashParticleScene = preload("res://Particles/particles_water_entered.tscn")
var effect_dustScene = preload("res://Particles/effect_dust.tscn")
var feathersParticleScene = preload("res://Particles/particles_feathers.tscn")
var particle_score_scene = preload("res://Particles/particle_score.tscn")


var direction = 0

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

var enemy_last = Node
var projectile_last = Node
var collectible_last = Node


@onready var sfx_collect1 = %collect1
@onready var timer = %Timer
@onready var animation_player = %AnimationPlayer
@onready var animation_player2 = %AnimationPlayer2
@onready var sprite = %AnimatedSprite2D
@onready var collisionCheck_delay = $collisionCheck_delay
@onready var main_collision = %CollisionShape2D

@onready var world = $/root/World
@onready var player = $/root/World.player

#PROPERTIES
@export var collectibleScoreValue = 50
@export var give_score = true
@export var animation_always = false
@export var floating = false
@export var is_key = false
@export var collectable = true
@export_enum("none", "loop_upDown", "loop_upDown_slight", "loop_scale") var loop_anim = "loop_upDown"
@export var hp = 5
@export var damageValue = 1

@export var is_shrineGem = false
@export var shrineGem_destructible = false
@export var shrineGem_giveScore = false
@export var shrineGem_spawnItems = false
@export var shrineGem_openPortal = false
@export var shrineGem_particle_amount = 25
@export var shrineGem_portal_level_ID = "MAIN_0"
@export_file("*.tscn") var shrineGem_level_filePath : String
@export var shrineGem_is_finalLevel = false
@export var shrineGem_checkpoint_offset = Vector2(320, -64)

@export var is_specialApple = "none" #options: "red", "blue", "golden"

@export var is_temporary_powerup = false
@export_enum("none", "higher_jump", "increased_speed", "teleport_forward_on_airJump") var temporary_powerup = "none"
@export var temporary_powerup_duration = 10

@export_file("*.tscn") var item_scene = "res://Collectibles/Gift_orangeBox.tscn" #preload("res://Collectibles/collectibleApple.tscn")
@export var spawnedAmount = 3
@export var item_posSpread = 100
@export var item_velSpread = 300

#GIFT
@export var is_gift = false
@export var inventory_item_scene = preload("res://Other/Scenes/User Interface/Inventory/inventoryItem.tscn")
@export var inventory_itemToSpawn = preload("res://Collectibles/collectibleApple.tscn")
@export var inventory_texture_region = Rect2(0, 0, 0, 0)
#GIFT END

#WEAPONS
@export var is_weapon = false
@export var is_SecondaryWeapon = false

@export var weapon_type = "none"
@export var attack_delay = 1.0
@export var secondaryWeapon_type = "none"
@export var secondaryAttack_delay = 1.0
#WEAPONS END

@export var is_healthItem = false
@export var rotting = false
@export var fall_when_button_pressed = false

@export var is_potion = false
@export var transform_into = "none"

@export var SPEED = 600.0
@export var SLOWDOWN = 200.0
@export var GRAVITY_SCALE = 1.0

@export var randomize_everything_onSpawn = false

@export var type : String
@export var debug = false
#PROPERTIES END


#OFFSCREEN START
func _ready():
	if randomize_everything_onSpawn:
		randomize_everything()
	
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	animation_player2.active = false
	$Area2D.set_monitorable(false)
	#OFFSCREEN END
	
	Globals.saveState_loaded.connect(saveState_loaded)
	
	animation_player.advance(abs(start_pos[0]) / 100)
	
	if loop_anim == "loop_upDown":
		animation_player.play("loop_upDown")
	elif loop_anim == "loop_upDown_slight":
		animation_player.play("loop_upDown_slight")
	elif loop_anim == "loop_scale":
		animation_player.play("loop_scale")
	
	if rotting:
		if get_node_or_null("$rotDelay"):
			%rotDelay.start()
	
	if shrineGem_is_finalLevel:
		modulate.g = 0.0
		modulate.b = 0.0
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.monitoring = true
	
	if global_position != Vector2(0, 0):
		start_pos = global_position
	
	await get_tree().create_timer(5, false).timeout
	checkpoint_active = true


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
	animation_player2.active = false
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
	animation_player2.active = true
	$Area2D.set_monitorable(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if removable or collected and not animation_player2.current_animation == "score_value" and not animation_player.current_animation == "remove":
		print("Removed already collected entity.")
		queue_free()


var bonus_material = preload("res://Other/Materials/bonus_material.tres")

func _on_collectible_entered(body):
	#if not body.is_in_group("player") and not body.is_in_group("player_projectile") and not body.is_in_group("enemies") and not body.is_in_group("Collectibles"):
		#return
	
	var entered_player = false
	var entered_projectile = false
	#var entered_enemy = false
	#var entered_collectible = false
	
	if body.is_in_group("player"):
		entered_player = true
	elif body.is_in_group("player_projectile"):
		entered_projectile = true
	#elif body.is_in_group("enemies"):
		#entered_enemy = true
	#elif body.is_in_group("Collectibles"):
		#entered_collectible = true
	else:
		return
	
	inside_check_enter(body)
	
	if entered_projectile and not floating and not is_shrineGem:
		sfx_collect1.pitch_scale = 0.5
		sfx_collect1.play()
		return
	
	if is_gift and get_tree().get_nodes_in_group("in_inventory").size() >= 6:
		return
	
	if is_temporary_powerup:
		reassign_player()
		world.reassign_player()
		
		player.powerup_timer.wait_time = temporary_powerup_duration
		player.powerup_timer.start()
		
		Globals.powerup_activated.emit()
		
		if temporary_powerup == "higher_jump":
			pass
		elif temporary_powerup == "increased_speed":
			pass
	
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
		animation_player2.play("score_value")
		random_pitch_collect()
		collected_special = true
	
	
	if is_healthItem:
		if entered_player and not collected:
			collected = true
			
			Globals.itemCollected.emit()
			Globals.increaseHp1.emit()
			
			animation_player.play("remove")
			sfx_collect1.pitch_scale = 1.0
			sfx_collect1.play()
			body.add_child(starParticleScene.instantiate())
			body.add_child(starParticleScene.instantiate())
			body.add_child(starParticleScene.instantiate())
			body.add_child(starParticleScene.instantiate())
			
			var feathersParticle = feathersParticleScene.instantiate()
			feathersParticle.position = position
			world.add_child(feathersParticle)
			
			feathersParticle = feathersParticleScene.instantiate()
			feathersParticle.position = position
			world.add_child(feathersParticle)
	
	
	if is_gift and entered_player and not collected or is_gift and entered_projectile and body.can_collect and not collected:
		if get_tree().get_nodes_in_group("in_inventory").size() < 6:
			var item = inventory_item_scene.instantiate()
			world.get_node("HUD/Inventory/InventoryContainer").add_child(item)
			item.item_toSpawn = inventory_itemToSpawn
			item.display_region_rect = inventory_texture_region
		
		world.get_node("HUD/Inventory").call("check_inventory")
		get_tree().call_group("in_inventory", "selected_check")
		
		#get_tree().call_group("in_inventory", "itemOrder_correct")
	
	
	if is_shrineGem:
		if entered_player:
			%AnimatedSprite2D.modulate.r = 0.3
			%AnimatedSprite2D.modulate.a = 0.5
			
		elif entered_projectile and not collected:
			if not body.upward_shot:
				velocity.y = -200
				velocity.x = 400 * body.direction
			else:
				velocity.y = -600
				
			stop_upDownLoopAnim = true
			floating = false
			if get_node_or_null("$hit1") : %hit1.play()
			%AnimationPlayer2.stop()
			if not shrineGem_is_finalLevel:
				%AnimationPlayer2.play("hit")
			else:
				%AnimationPlayer2.play("hit_finalLevel")
			
			var starParticle = starParticleScene.instantiate()
			starParticle.position = position
			world.add_child(starParticle)
			
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
					
					Globals.itemCollected.emit()
					
					if shrineGem_giveScore:
						award_score()
						
					if shrineGem_spawnItems:
						call_deferred("spawn_collectibles")
						Globals.boxBroken.emit()
					
					if shrineGem_openPortal:
						call_deferred("spawn_portal")
					
					if shrineGem_portal_level_ID != "none" and LevelTransition.get_node("%saved_progress").get("state_" + str(shrineGem_portal_level_ID)) == 0:
						LevelTransition.get_node("%saved_progress").set(("state_" + str(shrineGem_portal_level_ID)), -1)
						Globals.save_progress.emit()
	
	
	if collectable and not rotten and entered_player and not collected or collectable and not rotten and entered_projectile and body.can_collect and not collected:
		collected = true
		
		if give_score:
			award_score()
		
		Globals.itemCollected.emit()
		
		if is_potion:
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "Collectibles", "reassign_player")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "zone", "reassign_player")
			world.reassign_player()
			
			if transform_into == "rooster":
				world.player.transformInto_rooster()
			elif transform_into == "bird":
				world.player.transformInto_bird()
			elif transform_into == "chicken":
				world.player.transformInto_chicken()
			elif transform_into == "frog":
				world.player.transformInto_frog()
			elif transform_into == "pig":
				world.player.transformInto_pig()
			
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "Collectibles", "reassign_player")
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "zone", "reassign_player")
			world.reassign_player()
			
			Globals.player_transformed.emit()
		
		if is_key:
			world.key_collected()
			
			add_child(orbParticleScene.instantiate())
		
		
		if is_weapon:
			reassign_player()
			world.reassign_player()
			
			world.player.weaponType = weapon_type
			world.player.get_node("%attack_cooldown").wait_time = attack_delay
			
			add_child(orbParticleScene.instantiate())
			add_child(splashParticleScene.instantiate())
			add_child(effect_dustScene.instantiate())
			
			Globals.weapon_collected.emit()
		
		if is_SecondaryWeapon:
			reassign_player()
			world.reassign_player()
			world.player.secondaryWeaponType = secondaryWeapon_type
			world.player.get_node("%secondaryAttack_cooldown").wait_time = secondaryAttack_delay
			
			add_child(orbParticleScene.instantiate())
			add_child(splashParticleScene.instantiate())
			add_child(effect_dustScene.instantiate())
			
			Globals.secondaryWeapon_collected.emit()


func _on_collectible_exited(body):
	inside_check_exit(body)
	
	if is_shrineGem:
		if body.is_in_group("player"):
			if get_node_or_null("%AnimatedSprite2D"):
				%AnimatedSprite2D.modulate.r = 1.0
				%AnimatedSprite2D.modulate.a = 1.0
			
		elif body.is_in_group("player_projectile"):
			pass


func _on_timer_timeout():
	print("Collectible removed on timeout. (?)")
	queue_free()


func _on_animation_player_2_animation_finished(anim_name):
	if anim_name == "score_value" and not collected_special:
		removable = true


var velocity_x_last = 0.0
var direction_last = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var random_position_offset = Vector2(randf_range(0, 250), randf_range(0, 250)) 

func _physics_process(delta):
	if collected_special:
		position = lerp(position, world.player.position + random_position_offset, delta)
	
	
	if stop_upDownLoopAnim:
		stop_upDownLoop()
	
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not inside_wind:
		if collidable: #or is_shrineGem
			if is_on_floor():
				velocity.x = move_toward(velocity.x, SPEED * direction, SLOWDOWN * delta)
			else:
				velocity.x = move_toward(velocity.x, SPEED * direction, SLOWDOWN / 2 * delta)
	
	if player_inside:
		collidable = false
		collisionCheck_delay.start()
		
		reassign_player() # Remove this line as soon as all collectibles have their root node in the "Collectibles" group (and remove their Area2D's from that group).
		
		if player.direction == 0:
			direction = Globals.direction
		
		velocity.x = player.velocity.x * 1.2
		
		if abs(velocity.x) <= 150:
			velocity.x = 150 * direction
	
	
	if enemy_inside:
		if collidable:
			collidable = false
			collisionCheck_delay.start()
			
			if enemy_last.direction != 0:
				direction = enemy_last.direction
			
			velocity.x = enemy_last.velocity.x * 1.2
			
			if abs(velocity.x) <= 150:
				velocity.x = 150 * direction
	
	
	if projectile_inside:
		if projectile_last == null:
			return
		
		if collidable:
			collidable = false
			collisionCheck_delay.start()
			
			if projectile_last.direction != 0:
				direction = projectile_last.direction
			
			velocity.x = projectile_last.velocity.x * 1.2
			
			if abs(velocity.x) <= 150:
				velocity.x = 150 * direction
	
	
	handle_inside_zone(delta)
	
	
	if is_on_wall():
		velocity.x = -velocity_x_last / 2
		collidable = false
		collisionCheck_delay.start()
	
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
		pass


func saveState_loaded():
	animation_player.advance(abs(start_pos[0]) / 100)


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
	%AnimatedSprite2D.material = preload("res://Other/Materials/rotten_material.tres")


var player_inside = false
var enemy_inside = false
var projectile_inside = false

var collidable = true


func inside_check_enter(body):
	if body.is_in_group("player"):
		player_inside = true
		print("Player entered this collectible.")
		if collidable:
			collidable = false
			collisionCheck_delay.start()
			
			#direction = body.direction
		
	elif body.is_in_group("enemies"):
		enemy_last = body
		enemy_inside = true
		print("Enemy entered this collectible.")
		if collidable:
			collidable = false
			collisionCheck_delay.start()
			
			#direction = body.direction
		
	elif body.is_in_group("player_projectile"):
		projectile_last = body
		projectile_inside = true
		print("Collectible entered this collectible.")
		if collidable:
			collidable = false
			collisionCheck_delay.start()
			
			#direction = body.direction


func inside_check_exit(body):
	if body.is_in_group("player") or body.is_in_group("player_projectile") or body.is_in_group("enemies"):
		
		if body.is_in_group("player"):
			player_inside = false
			#direction = body.direction
			print("Player exitted.")
		
		if body.is_in_group("player_projectile"):
			projectile_inside = false
			#direction = body.direction
		
		if body.is_in_group("enemies"):
			enemy_inside = false
			#direction = body.direction
		
		
		if not player_inside and not projectile_inside and not enemy_inside:
			direction = 0


func stop_upDownLoop():
	animation_player.pause()
	if %AnimatedSprite2D.position.y > 0:
		%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
		%AnimatedSprite2D.position.y -= 1
		
	elif %AnimatedSprite2D.position.y < 0:
		%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
		%AnimatedSprite2D.position.y += 1


func award_score():
	Globals.level_score += collectibleScoreValue
	
	if Globals.collected_in_cycle > 1:
		Globals.combo_score += collectibleScoreValue * Globals.combo_tier
	
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
	
	sfx_collect1.play()
	
	%collectedDisplay.text = str(collectibleScoreValue * Globals.combo_tier)
	%collectedDisplay.position += Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	animation_player.play("remove")
	animation_player2.play("score_value")
	
	#Handle visual effect of collecting the 20th collectible in a streak (resulting in a x5 multiplier).
	if Globals.collected_in_cycle == 20:
		var max_multiplier_particle_amount = 50
		while max_multiplier_particle_amount > 0:
			max_multiplier_particle_amount -= 1
			call_deferred("spawn_particle_score", 2)
	
	# Handle double score particles (while a temporary powerup is active).
	if get_node_or_null("$/root/World/player"):
		if not player.double_score:
			return
		
		var effective_score = collectibleScoreValue * Globals.combo_tier
		var particle_amount : int
		
		if collectibleScoreValue * Globals.combo_tier < 25:
			particle_amount = effective_score
		else:
			particle_amount = 25
		
		while particle_amount > 0:
			particle_amount -= 1
			call_deferred("spawn_particle_score", 1)

func spawn_particle_score(scale_multiplier : int):
	var particle = particle_score_scene.instantiate()
	particle.position = position
	particle.scale = Vector2(scale_multiplier, scale_multiplier)
	world.add_child(particle)


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
		
		world.add_child(item)
	else:
		spawn_item_static()


func spawn_item_static():
	var item = load(item_scene).instantiate()
	item.position.x = global_position.x + rng.randf_range(item_posSpread, -item_posSpread)
	item.position.y = global_position.y + rng.randf_range(item_posSpread, -item_posSpread)
	
	world.add_child(item)



func spawn_portal():
	var portal = preload("res://Objects/shrine_portal.tscn").instantiate()
	portal.level_ID = shrineGem_portal_level_ID
	portal.level_filePath = shrineGem_level_filePath
	portal.particle_amount = shrineGem_particle_amount
	portal.position = start_pos
	
	world.add_child(portal)



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "collect_special":
		print("Special collectible has been deleted after the collect animation finished.")
		queue_free()


func random_pitch_collect():
	sfx_collect1.pitch_scale = (randf_range(0.8, 1.2))
	sfx_collect1.play()


#AREAS (water, wind, etc.)
var inside_wind = 0 # If above 0, the item is affected by wind.
var insideWind_direction_X = 0
var insideWind_direction_Y = 0
var insideWind_strength_X = 1.0
var insideWind_strength_Y = 1.0

var inside_water = 0
var insideWater_multiplier = 1

func handle_inside_zone(delta):
	if inside_wind:
		velocity.x += SPEED / 5 * insideWind_direction_X * insideWind_strength_X * delta


func reassign_player():
	player = get_tree().get_first_node_in_group("player_root")


#SAVE START
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
		"shrineGem_particleAmount" : shrineGem_particle_amount,
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


#Randomization
func randomize_everything():
	#prepare lists
	list_sprite = prepare_list_all("Assets/Graphics/sprites/packed/collectibles", [])
	list_collectible = prepare_list_all("Collectibles", [])
	list_enemy = prepare_list_all("Enemies", [])
	list_box = prepare_list_all("Boxes", [])
	list_projectile = prepare_list_all("Projectiles", ["charged", "lethalBall"])
	
	var list_every_object = list_collectible + list_box + list_enemy
	var list_without_enemies = list_collectible + list_box
	
	list_onDeath_item_scene = list_every_object
	list_onDeath_item_blacklist_enemy_scene = list_without_enemies
	list_onDeath_projectile_scene = list_projectile
	list_onDeath_secondaryProjectile_scene = list_projectile
	list_onHit_item_scene = list_every_object
	list_onHit_item_blacklist_enemy_scene = list_without_enemies
	list_onSpotted_item_scene = list_every_object
	list_onSpotted_item_blacklist_enemy_scene = list_without_enemies
	list_onSpotted_projectile_scene = list_projectile
	list_onSpotted_secondaryProjectile_scene = list_projectile
	list_onTimer_item_scene = list_every_object
	list_onTimer_item_blacklist_enemy_scene = list_without_enemies
	list_onTimer_projectile_scene = list_projectile
	list_onTimer_secondaryProjectile_scene = list_projectile
	list_bonusBox_item_scene = list_every_object
	list_bonusBox_item_blacklist_enemy_scene = list_without_enemies
	
	#properties
	collectibleScoreValue = randi_range(0, 25000)
	give_score = applyRandom_falseTrue(1, 6)
	animation_always = applyRandom_falseTrue(1, 4)
	floating = applyRandom_falseTrue(2, 1)
	is_key = applyRandom_falseTrue(3, 1)
	collectable = applyRandom_falseTrue(1, 9)
	loop_anim = applyRandom_fromList("list_loop_anim", -1)
	hp = randi_range(1, 5)
	damageValue = randi_range(0, 3)
	is_shrineGem = applyRandom_falseTrue(1, 4)
	shrineGem_destructible = applyRandom_falseTrue(6, 1)
	shrineGem_giveScore = applyRandom_falseTrue(1, 4)
	shrineGem_spawnItems = applyRandom_falseTrue(1, 5)
	shrineGem_openPortal = applyRandom_falseTrue(4, 1)
	shrineGem_particle_amount = randi_range(0, 300)
	shrineGem_portal_level_ID = applyRandom_fromList("list_level_ID", -1)
	shrineGem_level_filePath = str("res://Levels/", shrineGem_portal_level_ID, ".tscn")
	shrineGem_is_finalLevel = applyRandom_falseTrue(7, 1)
	shrineGem_checkpoint_offset = Vector2(randi_range(-320, 320), randi_range(-320, 320))
	is_specialApple = applyRandom_fromList("list_special_apple_type", -1)
	is_temporary_powerup = applyRandom_falseTrue(5, 1)
	temporary_powerup = applyRandom_fromList("list_temporary_powerup", -1)
	temporary_powerup_duration = randf_range(0.5, 15)
	spawnedAmount = randi_range(1, 12)
	item_posSpread = randi_range(-200, 200)
	item_velSpread = randi_range(-600, 600)
	item_scene = load(applyRandom_fromList("list_bonusBox_item_scene", -1))
	is_gift = applyRandom_falseTrue(6, 1)
	inventory_item_scene = preload("res://Other/Scenes/User Interface/Inventory/inventoryItem.tscn")
	inventory_itemToSpawn = load(applyRandom_fromList("list_bonusBox_item_scene", -1))
	inventory_texture_region = Rect2(0, 0, 0, 0)
	is_weapon = applyRandom_falseTrue(3, 1)
	is_SecondaryWeapon = applyRandom_falseTrue(3, 1)
	weapon_type = applyRandom_fromList("list_weapon", -1)
	attack_delay = randf_range(0.1, 3)
	secondaryWeapon_type = applyRandom_fromList("list_secondaryWeapon", -1)
	secondaryAttack_delay = randf_range(0.1, 3)
	is_healthItem = applyRandom_falseTrue(4, 1)
	rotting = applyRandom_falseTrue(5, 1)
	fall_when_button_pressed = applyRandom_falseTrue(6, 1)
	is_potion = applyRandom_falseTrue(7, 1)
	transform_into = applyRandom_fromList("list_potion", -1)
	SPEED = randi_range(-200, 1600)
	SLOWDOWN = randi_range(-100, 800)
	GRAVITY_SCALE = randi_range(-2, 4)
	
	
	modulate.r = randf_range(0, 1)
	modulate.g = randf_range(0, 1)
	modulate.b = randf_range(0, 1)
	modulate.a = randf_range(0.75, 1)
	
	sprite.sprite_frames = load(applyRandom_fromList("list_sprite", -1))
	main_collision.get_shape().radius = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_size().y / 2
	sprite.material.set_shader_parameter("Shift_Hue", randf_range(0, 1))
	if applyRandom_falseTrue(6, 1):
		scale.x = randi_range(0.05, 2)
		scale.y = scale.x
	if applyRandom_falseTrue(4, 1) : sprite.material = null

@onready var list_loop_anim = ["none", "loop_upDown", "loop_upDown_slight", "loop_scale"]
@onready var list_level_ID = ["MAIN_1", "MAIN_2", "MAIN_3", "MAIN_4", "MAIN_5", "MAIN_6", "MAIN_7", "MAIN_8"]
@onready var list_special_apple_type = ["red", "blue", "golden"]
@onready var list_temporary_powerup = ["none", "higher_jump", "increased_speed", "teleport_forward_on_airJump"]
@onready var list_weapon = ["weapon_basic", "weapon_short_shotDelay", "weapon_ice", "weapon_fire", "weapon_destructive_fast_speed", "weapon_veryFast_speed", "weapon_phaser"]
@onready var list_secondaryWeapon = ["secondaryWeapon_basic", "secondaryWeapon_fast"]
@onready var list_potion = ["rooster", "bird", "chicken"]

@onready var list_sprite = []
@onready var list_collectible = []
@onready var list_enemy = []
@onready var list_box = []
@onready var list_projectile = []

@onready var list_onDeath_item_scene = []
@onready var list_onDeath_item_blacklist_enemy_scene = []
@onready var list_onDeath_projectile_scene = []
@onready var list_onDeath_secondaryProjectile_scene = []
@onready var list_onHit_item_scene = []
@onready var list_onHit_item_blacklist_enemy_scene = []
@onready var list_onSpotted_item_scene = []
@onready var list_onSpotted_item_blacklist_enemy_scene = []
@onready var list_onSpotted_projectile_scene = []
@onready var list_onSpotted_secondaryProjectile_scene = []
@onready var list_onTimer_item_scene = []
@onready var list_onTimer_item_blacklist_enemy_scene = []
@onready var list_onTimer_projectile_scene = []
@onready var list_onTimer_secondaryProjectile_scene = []
@onready var list_bonusBox_item_scene = []
@onready var list_bonusBox_item_blacklist_enemy_scene = []

func prepare_list_all(directory_path : String, exclude : Array):
	var dir_path = "res://" + directory_path
	var dir = DirAccess.open(dir_path)
	var list = []
	
	if dir != null:
		var filenames = dir.get_files()
		
		for filename in filenames:
			if not filename.ends_with(".import") and not filename.ends_with(".gd"):
				list.append(dir_path + "/" + filename)
		
		var count = -1
		for exclusion in exclude:
			count += 1
			for filename in list:
				if filename.contains(exclude[count]):
					list.erase(filename)
	
	return list


func applyRandom_fromList(list_name, list_length):
	var list = get(str(list_name))
	var randomized_ID : int
	
	if list_length != -1:
		randomized_ID = randi_range(0, list_length)
	else:
		randomized_ID = randi_range(0, len(list) - 1)
	
	var randomized_property = list[randomized_ID]
	return randomized_property


func applyRandom_falseTrue(false_probability, true_probability):
	var randomized_number = randi_range(-false_probability, true_probability)
	if randomized_number <= 0:
		return false
	else:
		return true
