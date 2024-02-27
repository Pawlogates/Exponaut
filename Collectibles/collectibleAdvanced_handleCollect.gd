extends CharacterBody2D


var starParticleScene = preload("res://particles_special.tscn")
var starParticle2Scene = preload("res://particles_star.tscn")
var orbParticleScene = preload("res://particles_special2_multiple.tscn")
var starParticle = starParticleScene.instantiate()
var starParticle2 = starParticle2Scene.instantiate()
var orbParticle = orbParticleScene.instantiate()

var splashParticleScene = preload("res://particles_water_entered.tscn")
var splashParticle = splashParticleScene.instantiate()

var effect_dustScene = preload("res://effect_dust.tscn")
var effect_dust = effect_dustScene.instantiate()

var feathersParticleScene = preload("res://particles_feathers.tscn")
var feathersParticle = feathersParticleScene.instantiate()


var collected = false
var removable = false
var rotten = false

var button_pressed = false


@onready var collect_1 = %collect1
@onready var timer = %Timer
@onready var animation_player = %AnimationPlayer
@onready var animation_player_2 = %AnimationPlayer2
@onready var sprite = %AnimatedSprite2D


@export var collectibleScoreValue = 0
@export var hard_to_collect = false
@export var is_gift = false
@export var animation_always = false
@export var floating = false
@export var is_key = false
@export var collectable = true
@export var upDown_loop = false

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



#OFFSCREEN START

func _ready():
	add_to_group("loadingZone0")
	
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
	
	
	
	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	
	Globals.saveState_loaded.connect(saveState_loaded)
	
	
	if upDown_loop:
		animation_player.play("loop")
	
	
	if rotting:
		%rotDelay.start()
	
	
	
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.monitoring = true
	




func saveState_loaded():
	var xpos = self.global_position.x
	animation_player.advance(abs(xpos) / 100)
	




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
		queue_free()
	
	


var bonus_material = preload("res://Collectibles/bonus_material.tres")

@export var inventory_item_scene = preload("res://inventoryItem.tscn")
@export var inventory_itemToSpawn = preload("res://Collectibles/collectibleApple.tscn")
@export var inventory_texture_region = Rect2(0, 0, 0, 0)


func _on_collectible_entered(body):
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
			body.get_parent().get_parent().add_child(feathersParticle)
			
			feathersParticle = feathersParticleScene.instantiate()
			feathersParticle.position = position
			body.get_parent().get_parent().add_child(feathersParticle)
			
			return
			
		
	
	if is_gift and get_tree().get_nodes_in_group("in_inventory").size() >= 6:
		return
	
	if is_gift and body.is_in_group("player") and not collected or is_gift and body.is_in_group("player_projectile") and body.can_collect and not collected:
		if get_tree().get_nodes_in_group("in_inventory").size() < 6:
			var item = inventory_item_scene.instantiate()
			get_parent().get_parent().get_node("HUD/Inventory/InventoryContainer").add_child(item)
			item.item_toSpawn = inventory_itemToSpawn
			item.display_region_rect = inventory_texture_region
		
		get_parent().get_parent().get_node("HUD/Inventory").call("check_inventory")
		get_tree().call_group("in_inventory", "selected_check")
		
		#get_tree().call_group("in_inventory", "itemOrder_correct")
	
	
	
	if collectable and not rotten and body.is_in_group("player") and not collected or body.is_in_group("player_projectile") and body.can_collect and not collected:
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
		
		if is_potion:
			if transform_into == "rooster":
				get_parent().get_parent().reassign_player()
				get_parent().get_parent().player.transformInto_rooster()
			elif transform_into == "bird":
				get_parent().get_parent().reassign_player()
				get_parent().get_parent().player.transformInto_bird()
			elif transform_into == "chicken":
				get_parent().get_parent().reassign_player()
				get_parent().get_parent().player.transformInto_chicken()
			elif transform_into == "frog":
				get_parent().get_parent().reassign_player()
				get_parent().get_parent().player.transformInto_frog()
			elif transform_into == "pig":
				get_parent().get_parent().reassign_player()
				get_parent().get_parent().player.transformInto_pig()
		
		
		if is_key:
			get_parent().get_parent().key_collected()
			
			add_child(orbParticleScene.instantiate())
			
		
		if is_weapon:
			get_parent().get_parent().reassign_player()
			get_parent().get_parent().player.weaponType = weapon_type
			get_parent().get_parent().player.get_node("%attack_cooldown").wait_time = attack_delay
			
			add_child(orbParticleScene.instantiate())
			add_child(splashParticleScene.instantiate())
			add_child(effect_dustScene.instantiate())
		
		if is_SecondaryWeapon:
			get_parent().get_parent().reassign_player()
			get_parent().get_parent().player.secondaryWeaponType = secondaryWeapon_type
			get_parent().get_parent().player.get_node("%secondaryAttack_cooldown").wait_time = secondaryAttack_delay
			
			add_child(orbParticleScene.instantiate())
			add_child(splashParticleScene.instantiate())
			add_child(effect_dustScene.instantiate())





#SAVE START

var loadingZone = "loadingZone0"

func save():
	var save_dict = {
		"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"collected" : collected,
		
	}
	return save_dict

#SAVE END



func _on_timer_timeout():
	queue_free()


func _on_animation_player_2_animation_finished(_anim_name):
	removable = true











var velocity_x_last = 0
var direction_last = 0

var direction = 0
const SPEED = 600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	
	
	if collidable and direction:
		velocity.x = direction * SPEED
	elif collidable:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED / 2.5 * delta)
		
		
		
	if player_inside:
		if hard_to_collect or rotten:
			if collidable and abs(velocity.x) <= 250:
				if Globals.direction != 0:
					direction_last = Globals.direction
					
				velocity.x = 250 * direction_last
	
	
	if enemy_inside:
		if collidable:
			if direction != 0:
				direction_last = direction
			velocity.x = 250 * direction_last
		
		
	
	
	if is_on_wall():
		velocity.x = -velocity_x_last / 2
	elif velocity.x != 0:
		velocity_x_last = velocity.x
		
	
	if not collected and not floating or button_pressed:
		move_and_slide()
	
	
	
	if not animation_always:
		%AnimatedSprite2D.speed_scale = velocity.x / 100
	
	
	
	
	
	if fall_when_button_pressed:
		if button_pressed and %AnimatedSprite2D.position.y > 0:
			%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
			%AnimatedSprite2D.position.y -= 1
			print(%AnimatedSprite2D.position.y)
			
		elif button_pressed and %AnimatedSprite2D.position.y < 0:
			%AnimatedSprite2D.position.y = int(%AnimatedSprite2D.position.y)
			%AnimatedSprite2D.position.y += 1
			print(%AnimatedSprite2D.position.y)







var player_inside = false
var enemy_inside = false
var player_projectile_inside = false

var collidable = true


func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		player_inside = true
		if collidable and hard_to_collect or collidable and rotten:
			direction = area.get_parent().direction
		
	if area.is_in_group("enemies"):
		enemy_inside = true
		if collidable:
			direction = area.get_parent().direction
		
	if area.is_in_group("player_projectile"):
		player_projectile_inside = true
		if collidable:
			direction = area.get_parent().direction
			
		
	
	
	
	#SAVE START
	
	elif area.is_in_group("loadingZone_area"):
	
		remove_from_group("loadingZone0")
		remove_from_group("loadingZone1")
		remove_from_group("loadingZone2")
		remove_from_group("loadingZone3")
		remove_from_group("loadingZone4")
		remove_from_group("loadingZone5")
		
		loadingZone = area.loadingZone_ID
		add_to_group(loadingZone)
		
		#print("this ", name, " is in: ", loadingZone, is_in_group(loadingZone))
	
	
	#SAVE END



func _on_area_2d_area_exited(area):
	if area.is_in_group("player") or area.is_in_group("player_projectile") or area.is_in_group("enemies"):
		
		if area.is_in_group("player"):
			if hard_to_collect or rotten:
				player_inside = false
				direction = area.get_parent().direction
		
		if area.is_in_group("player_projectile"):
			player_projectile_inside = false
			direction = area.get_parent().direction
		
		if area.is_in_group("enemies"):
			enemy_inside = false
			direction = area.get_parent().direction
		
		
		
		
		if not player_inside and not player_projectile_inside and not enemy_inside:
			direction = 0
		
		if collidable:
			collidable = false
			$collisionCheck_delay.start()



func _on_collision_check_delay_timeout():
	collidable = true



func destroy_self():
	queue_free()



func on_button_press():
	if not collected:
		velocity.y = 0
		button_pressed = true
		animation_player.pause()








func _on_rot_delay_timeout():
	rotten = true
	%AnimatedSprite2D.material = preload("res://Collectibles/rotten_material.tres")
