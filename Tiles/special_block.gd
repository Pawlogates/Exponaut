extends CharacterBody2D


@export var SPEED = 250.0


@export var item_scene = preload("res://Collectibles/collectibleOrange.tscn")
var item = item_scene.instantiate()


var starParticleScene = preload("res://particles_star.tscn")
var starParticle = starParticleScene.instantiate()
var hit_effectScene = preload("res://hit_effect.tscn")
var hit_effect = hit_effectScene.instantiate()
var dead_effectScene = preload("res://dead_effect.tscn")
var dead_effect = dead_effectScene.instantiate()


var starParticle2Scene = preload("res://particles_star.tscn")
var orbParticleScene = preload("res://particles_special2_multiple.tscn")

var starParticle2 = starParticle2Scene.instantiate()
var orbParticle = orbParticleScene.instantiate()

var splashParticleScene = preload("res://particles_water_entered.tscn")
var splashParticle = splashParticleScene.instantiate()

var effect_dustScene = preload("res://effect_dust.tscn")
var effect_dust = effect_dustScene.instantiate()


#SPECIAL PROPERTIES

@export var immortal = false
@export var floating = false
@export var start_floating = false
@export var breakable = false
@export var bouncy = false
@export var spawns_items = false
@export var toggles_skull_blocks = false

@export var remove_after_delay = false
@export var remove_delay = 1.0

@export var collectibleAmount = 3

@export var movement_type = "normal"
@export var is_spikeBlock = false
@export var damage = 1

@export var destructible_weapon = false



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor() and not floating and blockType == "none":
		velocity.y += gravity / 2 * delta
	elif floating:
		velocity.y = 0
	
	
	if direction and blockType != "none":
		velocity.x = move_toward(velocity.x, SPEED * direction, SPEED * delta)
	elif velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	if direction_V and blockType != "none":
		velocity.y = move_toward(velocity.y, SPEED * direction_V, SPEED * delta)
	
	
	
	if not floating:
		if movement_type == "normal":
			var collision = move_and_slide()
			if collision:
				pass
			
		if movement_type == "iceCube":
			var collision = move_and_slide()
			velocity.x = move_toward(velocity.x, 0, SPEED / 2 * delta)
			if collision:
				pass
		
		if movement_type == "bouncy":
			var collision = move_and_slide()
			if collision:
				velocity = Vector2(200, -300)
	




func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		
		if bouncy and not destroyed and area.get_parent().velocity.y > 50:
			if Input.is_action_pressed("jump"):
				area.get_parent().velocity.y = -600
			else:
				area.get_parent().velocity.y = -300
			
			if toggles_skull_blocks:
				get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "skull_block", "skull_block_toggle")
			
			
			if breakable:
				effect_dust = effect_dustScene.instantiate()
				effect_dust.global_position = global_position
				get_parent().add_child(effect_dust)
				
				$AudioStreamPlayer2D.play()
				%AnimationPlayer2.play("destroyed")
				
				if spawns_items:
					call_deferred("spawn_collectibles")
				
				await get_tree().create_timer(1, false).timeout
				queue_free()
			
			
			
			if not immortal:
				add_child(dead_effect)
				%AnimatedSprite2D.play("destroyed")
			
			Globals.boxBroken.emit()
		
		
		if is_spikeBlock:
			if damage == 1:
				Globals.playerHit1.emit()
			elif damage == 2:
				Globals.playerHit2.emit()
			elif damage == 3:
				Globals.playerHit3.emit()
			elif damage == 100:
				Globals.kill_player.emit()
		
		
	if area.is_in_group("player_projectile"):
		if not destroyed:
			if not immortal:
				destroyed = true
			
			if destructible_weapon:
				if area.is_in_group("destructive"):
					effect_dust = effect_dustScene.instantiate()
					effect_dust.global_position = global_position
					get_parent().add_child(effect_dust)
					
					queue_free()
					
				
			
			if toggles_skull_blocks:
				get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "skull_block", "skull_block_toggle")
			
			
			if breakable:
				effect_dust = effect_dustScene.instantiate()
				effect_dust.global_position = global_position
				get_parent().add_child(effect_dust)
				
				$AudioStreamPlayer2D.play()
				%AnimationPlayer2.play("destroyed")
				
				if spawns_items:
					call_deferred("spawn_collectibles")
				
				await get_tree().create_timer(1, false).timeout
				queue_free()
			
			
			if not immortal and breakable:
				add_child(dead_effect)
				%AnimatedSprite2D.play("destroyed")
			
			Globals.boxBroken.emit()
		
	
	
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
		
		#print("this object is in: ", loadingZone)

	#SAVE END





#IS IN VISIBLE RANGE?

func offScreen_unload():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	#sprite.pause()
	#sprite.visible = false
	$Sprite2D/AnimationPlayer.active = false
	$Area2D.set_monitorable(false)
	
	
	

func offScreen_load():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	#sprite.play()
	#sprite.visible = true
	$Sprite2D/AnimationPlayer.active = true
	
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.set_monitorable(true)
	$Area2D.set_monitoring(true)
	
	

func _ready():

	add_to_group("loadingZone0")
	
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	#sprite.pause()
	#sprite.visible = false
	$Sprite2D/AnimationPlayer.active = false
	$Area2D.set_monitorable(false)
	
	
	#if not destroyed:
		#%AnimatedSprite2D.play("idle")
	
	
	
	
	if remove_after_delay:
		%Timer.wait_time = remove_delay
		%Timer.start()




var destroyed = false

func spawn_collectibles():
	while collectibleAmount > 0:
		collectibleAmount -= 1
		spawn_item()
		
	
	hit_effect = hit_effectScene.instantiate()
	add_child(hit_effect)




var rng = RandomNumberGenerator.new()

func spawn_item():
	item = item_scene.instantiate()
	item.position = position
	item.velocity.x = rng.randf_range(300.0, -300.0)
	item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	get_parent().get_parent().add_child(item)
	




#SAVE START

var loadingZone = "loadingZone0"

func save():
	var save_dict = {
		"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"destroyed" : destroyed,
		
	}
	return save_dict

#SAVE END




func _on_timer_timeout():
	effect_dust = effect_dustScene.instantiate()
	effect_dust.global_position = global_position
	get_parent().add_child(effect_dust)
	
	queue_free()








#ON BUTTON PRESSED

@export var blockType = "none"
@export var blockDirection = -1
var direction = 0
var direction_V = 0


func greenButton_pressed():
	print(blockType)
	if blockType == "green":
		if blockDirection == 0:
			direction = -1
		
		elif blockDirection == 1:
			direction = 1
	

func blueButton_pressed():
	print(blockType)
	if blockType == "blue":
		if blockDirection == 0:
			direction_V = -1
		
		elif blockDirection == 1:
			direction_V = 1
	

func redButton_pressed():
	print(blockType)
	if blockType == "red":
		%AnimationPlayer.play("red_disable")





#BUTTON BACK

func greenButton_back():
	if blockType == "green":
		if blockDirection == 0:
			direction = -1
		
		elif blockDirection == 1:
			direction = 1


func blueButton_back():
	if blockType == "blue":
		if blockDirection == 0:
			direction_V = -1
		
		elif blockDirection == 1:
			direction_V = 1


func redButton_back():
	if blockType == "red":
		%AnimationPlayer.play("red_enable")



