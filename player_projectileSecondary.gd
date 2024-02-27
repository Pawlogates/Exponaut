extends CharacterBody2D


const SPEED = 50.0

var hit_ground = false
@export var damageValue = 1
var direction = 0

var velocity_Y_last = 0
var velocity_X_last = 0

var enemyProjectile = false
var playerProjectile = true


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
@export var bouncy_onGround = false
@export var spawns_items = false
@export var toggles_skull_blocks = false

@export var remove_after_delay = false
@export var remove_delay = 1.0

@export var collectibleAmount = 3

@export var movement_type = "normal"

@export var destructible_strongWeapon = false
@export var destructible_anyWeapon = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor() and not floating:
		velocity.y += gravity * delta
	else:
		if not bouncy_onGround:
			velocity.y = 0
	
	
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
		
		if bouncy_onGround:
			velocity.x = -velocity_X_last
		
	
	if not bouncy_onGround and velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
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
	
	
	
	if velocity.y != 0:
		velocity_Y_last = velocity.y
	if velocity.x != 0:
		velocity_X_last = velocity.x
	
	if is_on_floor() and not hit_ground:
		if not bouncy_onGround:
			hit_ground = true
			%AnimatedSprite2D.play("hit_ground")
			$Area2D.set_monitorable(false)
			$Area2D.set_monitoring(false)
			
			await get_tree().create_timer(10, false).timeout
			queue_free()
		
		if not bouncy_onGround:
			velocity.x = 0
		else: 
			velocity.y = -velocity_Y_last
			$AudioStreamPlayer2D.play()
		
	



func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		if enemyProjectile:
			Globals.playerHit1.emit()
		
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
				%AnimationPlayer.play("hit_ground")
				
				if spawns_items:
					call_deferred("spawn_collectibles")
				
				await get_tree().create_timer(1, false).timeout
				queue_free()
			
			
			
			if not immortal:
				add_child(dead_effect)
				%AnimatedSprite2D.play("hit_ground")
			
			Globals.boxBroken.emit()
		
		
		
	if area.is_in_group("player_projectile"):
		if not destroyed:
			if not immortal:
				destroyed = true
			
			if destructible_strongWeapon:
				if area.is_in_group("destructive"):
					effect_dust = effect_dustScene.instantiate()
					effect_dust.global_position = global_position
					get_parent().add_child(effect_dust)
					
					queue_free()
			
			elif destructible_anyWeapon:
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
				%AnimationPlayer.play("hit_ground")
				
				if spawns_items:
					call_deferred("spawn_collectibles")
				
				await get_tree().create_timer(1, false).timeout
				queue_free()
			
			
			if not immortal and breakable:
				add_child(dead_effect)
				%AnimatedSprite2D.play("hit_ground")
			
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
	%AnimatedSprite2D/AnimationPlayer.active = false
	$Area2D.set_monitorable(false)
	$Area2D.set_monitoring(false)
	
	

func offScreen_load():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	#sprite.play()
	#sprite.visible = true
	%AnimatedSprite2D/AnimationPlayer.active = true
	
	
	if not hit_ground or bouncy_onGround:
		await get_tree().create_timer(0.2, false).timeout
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
	%AnimatedSprite2D/AnimationPlayer.active = false
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
		"hit_ground" : hit_ground,
		
	}
	return save_dict

#SAVE END




func _on_timer_timeout():
	effect_dust = effect_dustScene.instantiate()
	effect_dust.global_position = global_position
	get_parent().add_child(effect_dust)
	
	queue_free()
