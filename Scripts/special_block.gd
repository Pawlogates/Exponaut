extends CharacterBody2D

var direction = 0
var direction_y = 0

var block_movement = true

var velocity_x_last = 0.0


#SPECIAL PROPERTIES
@export var SPEED = 250.0
@export var SPEED_Y = 500.0
@export var ACCELERATION = 250.0
@export var ACCELERATION_V = 1.0
@export var SLOWDOWN = 250.0
@export var GRAVITY_SCALE = 1.0

@export var is_toggleBlock = false
@export var toggleBlock_is_active = true
@export var immortal = false
@export var floating = false
@export var start_floating = false
@export var breakable = false
@export var hp = 3
@export var bouncy = false
@export var spawns_items = false
@export var toggles_toggleBlocks = false

@export var remove_after_delay = false
@export var remove_delay = 1.0

@export var collectibleAmount = 3
@export var item_scene = preload("res://Enemies/togglebot.tscn")

@export var block_movement_onSpawn = true
@export var movement_type = "normal"
@export var is_spikeBlock = false
@export var damageValue = 1

@export var destructible_weapon = false

@export var blockType = "normal"
@export var blockDirection = -1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor() and not floating and blockType == "normal":
		velocity.y = move_toward(velocity.y, SPEED_Y, ACCELERATION_V * 500 * delta)
	
	elif floating:
		velocity.y = move_toward(velocity.y, 0, SPEED_Y * ACCELERATION_V * delta)
	
	
	if not inside_wind:
		if direction and blockType != "normal":
			velocity.x = move_toward(velocity.x, SPEED * direction, SPEED * delta)
		elif velocity.x != 0:
			velocity.x = move_toward(velocity.x, 0, SLOWDOWN * delta)
		
		if direction_y and blockType != "normal":
			velocity.y = move_toward(velocity.y, SPEED * direction_y, SPEED * delta)
	
	handle_inside_zone(delta)
	
	if is_on_wall():
		velocity.x = -velocity_x_last / 2
	
	elif velocity.x != 0:
		velocity_x_last = velocity.x
	
	
	if not floating:
		if block_movement:
			return
		
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
			
			if toggles_toggleBlocks:
				get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")
			
			
			if breakable:
				var effect_dust = Globals.scene_effect_dust.instantiate()
				effect_dust.global_position = global_position
				get_parent().add_child(effect_dust)
				
				$AudioStreamPlayer2D.play()
				%AnimationPlayer2.play("destroyed")
				
				if spawns_items:
					call_deferred("spawn_collectibles")
				
				await get_tree().create_timer(1, false).timeout
				queue_free()
			
			
			
			if not immortal:
				var dead_effect = Globals.scene_effect_dead_enemy
				add_child(dead_effect)
				%AnimatedSprite2D.play("destroyed")
			
			Globals.boxBroken.emit()
		
		
		if is_spikeBlock:
			if damageValue == 1:
				Globals.playerHit1.emit()
			elif damageValue == 2:
				Globals.playerHit2.emit()
			elif damageValue == 3:
				Globals.playerHit3.emit()
			elif damageValue == 100:
				Globals.kill_player.emit()
		
		
	if area.is_in_group("player_projectile"):
		if not destroyed:
			if not immortal:
				destroyed = true
			
			if destructible_weapon:
				if area.is_in_group("destructive"):
					var effect_dust = Globals.scene_effect_dust.instantiate()
					effect_dust.global_position = global_position
					get_parent().add_child(effect_dust)
					
					queue_free()
			
			
			if toggles_toggleBlocks:
				get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")
			
			
			if breakable:
				var effect_dust = Globals.dust.instantiate()
				effect_dust.global_position = global_position
				get_parent().add_child(effect_dust)
				
				$AudioStreamPlayer2D.play()
				%AnimationPlayer2.play("destroyed")
				
				if spawns_items:
					call_deferred("spawn_collectibles")
				
				await get_tree().create_timer(1, false).timeout
				queue_free()
			
			
			if not immortal and breakable:
				var dead_effect = Globals.scene_effect_dead_enemy
				add_child(dead_effect)
				%AnimatedSprite2D.play("destroyed")
			
			Globals.boxBroken.emit()


#SAVE
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"destroyed" : destroyed,
		"toggleBlock_is_active" : toggleBlock_is_active,
		"direction" : direction,
		"direction_y" : direction_y,
	}
	return save_dict
#!SAVE


#IS IN VISIBLE RANGE?
func offScreen_unload():
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	if get_node_or_null("$Area2D"):
		$Area2D.set_monitorable(false)


func offScreen_load():
	set_process(true)
	set_physics_process(true)
	
	set_process_input(true)
	set_process_internal(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	if get_node_or_null("$Area2D"):
		$Area2D.set_monitorable(true)
		await get_tree().create_timer(0.5, false).timeout
		$Area2D.set_monitoring(true)


func _ready():
	$VisibleOnScreenNotifier2D.visible = true
	
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	
	if get_node_or_null("$Area2D"):
		$Area2D.set_monitorable(false)
	
	if remove_after_delay:
		%Timer.wait_time = remove_delay
		%Timer.start()
	
	if not block_movement_onSpawn:
		block_movement = false
	
	await get_tree().create_timer(0.25, false).timeout
	
	if is_toggleBlock:
		if toggleBlock_is_active:
			$Sprite2D.region_rect = Rect2(384, 896, 64, 64)
			$CollisionShape2D.disabled = false
		
		else:
			$Sprite2D.region_rect = Rect2(448, 896, 64, 64)
			$CollisionShape2D.disabled = true
	
	if block_movement_onSpawn:
		await get_tree().create_timer(0.25, false).timeout
	
	block_movement = false


var destroyed = false

func spawn_collectibles():
	while collectibleAmount > 0:
		collectibleAmount -= 1
		spawn_item()
	
	var hit_effect = Globals.hit.instantiate()
	add_child(hit_effect)


var rng = RandomNumberGenerator.new()

func spawn_item():
	var item = item_scene.instantiate()
	item.position = position
	item.velocity.x = rng.randf_range(300.0, -300.0)
	item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	get_parent().get_parent().add_child(item)


func _on_timer_timeout():
	var effect_dust = Globals.dust.instantiate()
	effect_dust.global_position = global_position
	get_parent().add_child(effect_dust)
	
	queue_free()


#BUTTON PRESSED
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
			direction_y = -1
		
		elif blockDirection == 1:
			direction_y = 1

func redButton_pressed():
	print(blockType)
	if blockType == "red":
		%AnimationPlayer.play("red_disable")


#BUTTON BACK
func greenButton_back():
	pass
	#if blockType == "green":
		#if blockDirection == 0:
			#direction = -1
		#
		#elif blockDirection == 1:
			#direction = 1

func blueButton_back():
	pass
	#if blockType == "blue":
		#if blockDirection == 0:
			#direction_y = -1
		#
		#elif blockDirection == 1:
			#direction_y = 1

func redButton_back():
	if blockType == "red":
		%AnimationPlayer.play("red_enable")


#TOGGLE BLOCK
func toggleBlock_toggle():
	if not toggleBlock_is_active:
		$Sprite2D.region_rect = Rect2(384, 896, 64, 64)
		$CollisionShape2D.disabled = false
		toggleBlock_is_active = true
		#z_index += 1
	
	else:
		$Sprite2D.region_rect = Rect2(448, 896, 64, 64)
		$CollisionShape2D.disabled = true
		toggleBlock_is_active = false
		#z_index -= 1
	
	if $VisibleOnScreenNotifier2D.is_on_screen():
		var dust = Globals.dust.instantiate()
		#dust.anim_slow = true
		add_child(dust)
		var stars = Globals.scene_particle_star.instantiate()
		add_child(stars)
		var particles_special_multiple = Globals.scene_particle_special2_multiple.instantiate()
		add_child(particles_special_multiple)


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
		velocity.x += SPEED * insideWind_direction_X * insideWind_strength_X * delta
