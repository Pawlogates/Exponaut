extends entity_basic

func _ready():
	basic_on_spawn()
	reassign_general()
	reassign_movement_type_id()

func _process(delta):
	handle_movement(delta)
	
	if direction_x != 0:
		direction_active_x = direction_x
	
	if look_at_player_x:
		if position.x < Player.position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	
	if look_at_player_y:
		if position.y < Player.position.y:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
	
	if look_at_player_rotate:
		rotation_degrees = 0
		look_at(Player.position)
		rotation_degrees += look_at_player_rotate_offset
	
	if removable:
		Globals.message_debug("Removed already collected entity.")
		queue_free()
	
	if on_collected_effect_special:
		position = lerp(position, World.player.position + random_position_offset, delta)
	
	if on_collected_effect_thrownAway:
		if effect_thrownAway_active:
			effect_thrownAway(delta)
	
	if is_on_wall():
		if direction_x: # If moving horizontally. Vertically moving projectiles need to have this not execute, as it would interfere with flipping of the sprite when REFLECTED off angled surfaces. Note that REFLECTED movement ignores gravity and is unrelated to BOUNCING behavior.
			
			if direction_x < 0:
				sprite.flip_h = false
			
			else:
				sprite.flip_h = true
		
		# if can_collide:
		# Handle straight surface bounce.
		reflect_straight()
		
		if gravity == 0:
			# Handle slope surface bounce
			reflect_slope()
			
			if direction_y > 0:
				rotation_degrees = 90
			elif direction_y < 0:
				rotation_degrees = -90
	
	move_and_slide()
	
	if effect_shrink:
		scale.x = move_toward(scale.x, 0.1, delta * 2)
		scale.y = move_toward(scale.y, 0.1, delta * 2)
	
	if debug:
		pass


func handle_gravity(delta):
	if can_move:
		if can_move_y:
			if not is_on_floor():
				velocity.y += fall_speed * gravity * gravity_multiplier_y * delta


func _on_scan_visible_screen_entered() -> void:
	basic_on_active()

func _on_scan_visible_screen_exited() -> void:
	basic_on_inactive()


func direction_toward_target_x(target):
	if position.x < Player.position.x:
		direction_x = 1
	else:
		direction_x = -1

func direction_toward_target_y(target : Node):
	if position.y < target.position.y:
		direction_y = 1
	else:
		direction_y = -1


# The entity's HITBOX has been touched by another entity's HITBOX.
func _on_hitbox_area_entered(area: Area2D) -> void:
	var target = area.get_parent()
	
	# Executes only if the node is a valid one to interact with.
	if not target.is_in_group("Player") and target.is_in_group("Entity") : return
	else : Globals.dm(str("Player's Main Hitbox has entered an entity's Main Hitbox (%s, %s)" % [entity_name, entity_type]), "CRIMSON")
	
	
	# Assigns an "inside" variable depending on the node that just entered this entity. Used mostly for the pushing movement logic.
	inside_check_enter(target)
	
	# Tries to COLLECT the entity.
	if collectable and not collected and target.can_collect:
		if not rotten or target.family != "Player":
			handle_collectable(target)
	
	if breakable : handle_breakable(target)

func _on_hitbox_area_exited(target: Area2D) -> void:
	inside_check_exit(target)
	
	if breakable_advanced_on_touch_modulate != Color(1, 1, 1, 1):
		if inside_player:
			sprite.modulate = breakable_advanced_on_touch_modulate


func reassign_movement_type_id():
	movement_type_id = Globals.l_entity_movement.find(movement_type)


# Functionality around entities being inside other entities, which causes them to modify their movement. This is the case when this entity's HITBOX is inside another entity's MAIN COLLISION.
# Note that this does not include behaviors such as the entity being COLLECTED by the player, or being HIT by a projectile.
var inside_player = 0
var inside_player_last = Node
var inside_player_all : Array = []
var inside_entity = 0
var inside_entity_last = Node
var inside_entity_all : Array = []

var inside_projectile = 0
var inside_projectile_last = Node
var inside_projectile_all : Array = []
var inside_enemy = 0
var inside_enemy_last = Node
var inside_enemy_all : Array = []
var inside_box = 0
var inside_box_last = Node
var inside_box_all : Array = []
var inside_block = 0
var inside_block_last = Node
var inside_block_all : Array = []

var is_collidable = true

func inside_check_enter(body):
	if body.is_in_group("Player"):
		
		inside_player += 1
		inside_player_last = body
		inside_player_all += body
	
	elif body.is_in_group("Entity"):
		
		inside_entity += 1
		inside_entity_last = body
		inside_entity_all += body
		
		if body.entity_type == "projectile":
			inside_projectile += 1
			inside_projectile_last = body
			inside_projectile_all += body
		
		if body.entity_type == "enemy":
			inside_enemy += 1
			inside_enemy_last = body
			inside_enemy_all += body
		
		if body.entity_type == "box":
			inside_box += 1
			inside_box_last = body
			inside_box_all += body
		
		if body.entity_type == "block":
			inside_block += 1
			inside_block_last = body
			inside_block_all += body
	
	else:
		return
	
	if collidable and is_collidable:
		
		if inside_player > 0:
			Globals.message_debug("Player entered an entity " + "(" + entity_name + ").")
		else:
			Globals.message_debug("An entity " + "(" + body.entity_name + "). has entered another entity " + "(" + entity_name + ").")
		
		collidable = false
		cooldown_collidable.wait_time = collidable_cooldown
		cooldown_collidable.start()
		
		if enteredFromAboveAndNotMoving_enable and body.position.y <= position.y and abs(body.velocity.x) < 25:
				direction_x = 0
				velocity.y = enteredFromAboveAndNotMoving_velocity
		
		elif on_entityEntered_change_direction_copyEntity:
			
			direction_x = body.direction
		
		elif on_entityEntered_change_direction_basedOnPosition:
				
			if body.position.x > position.x:
				direction_x = 1
				
			else:
				direction_x = -1


func inside_check_exit(body):
	if body.is_in_group("Player"):
		
		inside_player -= 1
		inside_player_last = body
		inside_player_all -= body
	
	elif body.is_in_group("Entity"):
		
		inside_entity -= 1
		inside_entity_last = body
		inside_entity_all -= body
	
	else:
		return
	
	
	if not inside_player and not inside_entity:
		direction_x = 0


# The entity moves (the function is executed every frame) according to its movement type, and only one is active at a time. (This is unlike the other properties, which synergize with eachother to provide a very vast selection of unique object behaviors).
# Movement types: 0 - "normal", 1 - "move_x", 2 - "move_y", 3 - "move_xy", 4 - "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted".

@onready var movement_function_name = "movement_" + movement_type

func handle_movement(delta):
	call(movement_function_name, delta)
	#call("movement_" + str(Globals.l_entity_movement[movement_type_id]), delta)


# Movement types:

# The entity doesn't move by itself, it just falls down to the ground and can be affected by other entities and the player.
func movement_normal(delta):
	if not dead:
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)

# The entity always attempts to move horizontally, as it's direction can never be equal to 0.
func movement_move_x(delta):
	handle_gravity(delta)
	
	if direction_x == 0:
		direction_active_x = direction_x # Active means "last value considered active", which in case of velocity, would be anything except 0 (but in this case its actually everything between -25 and 25).
	
	if not dead:
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)

# Same as above, but vertical.
func movement_move_y(delta):
	if direction_y == 0:
		direction_y = direction_active_y
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)

# Same as above, but both horizontal and vertical.
func movement_move_xy(delta):
	if direction_x == 0:
		direction_x = direction_active_x
	
	if direction_y == 0:
		direction_y = direction_active_y
	
	if not dead:
		move_in_direction_y(delta)
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)

# Entity moves horizontally, towards the player.
func movement_follow_player_x(delta):
	handle_gravity(delta)
	
	if can_turn:
		if position.x < Player.position.x:
			direction_x = 1
		else:
			direction_x = -1
	
	if not dead:
		move_in_direction_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)

# Same as above, but vertical.
func movement_follow_player_y(delta):
	if can_turn:
		if position.y < Player.position.y:
			direction_y = 1
		else:
			direction_y = -1
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)

# Same as above, but both horizontal and vertical.
func movement_follow_player_xy(delta):
	if can_turn:
		if position.x < Player.position.x:
			direction_x = 1
		else:
			direction_x = -1
		
		if position.y < Player.position.y:
			direction_y = 1
		else:
			direction_y = -1
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func movement_follow_player_x_if_spotted(delta):
	handle_gravity(delta)
	
	if spotted and not dead:
		movement_follow_player_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_follow_player_y_if_spotted(delta):
	if spotted and not dead:
		move_in_direction_x(delta)
		movement_follow_player_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)


func movement_follow_player_xy_if_spotted(delta):
	if spotted and not dead:
		movement_follow_player_xy(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)

# Entity will "chase" the player, which means rapidly closing the distance between them, no matter the gap length.
func movement_chase_player_x(delta):
	handle_gravity(delta)
	
	if not dead:
		movement_chase_player_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_chase_player_y(delta):
	if not dead:
		movement_chase_player_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func movement_chase_player_xy(delta):
	if not dead:
		movement_chase_player_xy(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func movement_chase_player_x_if_spotted(delta):
	handle_gravity(delta)
	
	if spotted and not dead:
		movement_chase_player_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func movement_chase_player_y_if_spotted(delta):
	if spotted and not dead:
		movement_chase_player_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
		move_toward_zero_velocity_y(delta)
	
	if dead:
		handle_gravity(delta)


func movement_chase_player_xy_if_spotted(delta):
	if spotted and not dead:
		movement_chase_player_xy(delta)
	else:
		move_toward_zero_velocity_x(delta)
		move_toward_zero_velocity_y(delta)
	
	if dead:
		handle_gravity(delta)

# Wave-like movement on the axis opposite to the straight line movement happening alongside it.
# Note: This movement type (wave_x and wave_y) is best used alongside the "can_move_y" or "can_move_x" being set to false.
var w_target_velocity_x = -100

func movement_wave_x(delta):
	if not dead:
		if velocity.y in range(direction_y * w_target_velocity_x,direction_y * w_target_velocity_x * 100):
			
			direction_y *= -1
	
	velocity.y = move_toward(velocity.y, w_target_velocity_x, delta * speed * speed_multiplier_y)
	
	if not dead:
		movement_move_x(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


var w_target_velocity_y = 100

func movement_wave_y(delta):
	if not dead:
		if velocity.y in range(direction_y * w_target_velocity_y,direction_y * w_target_velocity_y * 100):
			
			direction_y *= -1
	
	velocity.y = move_toward(velocity.y, w_target_velocity_y, delta * speed * speed_multiplier_y)
	
	if not dead:
		movement_move_x(delta)
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


#"move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted"
func move_around_startPosition_x(delta):
	handle_gravity(delta)
	
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)
	
	else:
		move_toward_zero_velocity_x(delta)


func move_around_startPosition_y(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)
		movement_move_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func move_around_startPosition_xy(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		if position.y < start_pos.y:
			direction_y = -1
		else:
			direction_y = 1
		
		movement_move_x(delta)
		movement_move_y(delta)
	
	else:
		move_toward_zero_velocity_x(delta)
		handle_gravity(delta)


func move_around_startPosition_x_if_not_spotted(delta):
	handle_gravity(delta)
	
	if spotted and not dead:
		move_around_startPosition_x(delta)
	else:
		move_toward_zero_velocity_x(delta)


func move_around_startPosition_y_if_not_spotted(delta):
	if spotted and not dead:
		move_around_startPosition_y(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)


func move_around_startPosition_xy_if_not_spotted(delta):
	if spotted and not dead:
		move_around_startPosition_x(delta)
	else:
		move_toward_zero_velocity_x(delta)
	
	if dead:
		handle_gravity(delta)


func reassign_general():
	World = Globals.reassign_general()[0]
	Player = Globals.reassign_general()[1]
	
	gravity = Globals.gravity


func _on_cooldown_collidable_timeout() -> void:
	is_collidable = true


func _on_cooldown_remove_corpse_timeout() -> void:
	var effect_death = Globals.scene_effect_dead_enemy.instantiate()
	effect_death.position = position
	Globals.World.add_child(effect_death)


func move_toward_zero_velocity_x(delta):
	velocity.x = move_toward(velocity.x, 0, delta * friction)

func move_toward_zero_velocity_y(delta):
	velocity.y = move_toward(velocity.y, 0, delta * friction)

func move_in_direction_x(delta):
	velocity.x = move_toward(velocity.x, direction_x * speed * speed_multiplier_x, delta * acceleration * acceleration_multiplier_x)

func move_in_direction_y(delta):
	velocity.y = move_toward(velocity.y, direction_y * speed * speed_multiplier_y, delta * acceleration * acceleration_multiplier_y)

func chase_target_x(delta, target : Node):
	position.x = lerp(position.x, Player.position, delta)

func chase_target_y(delta, target : Node):
	position.y = lerp(position.y, Player.position, delta)

func chase_target_xy(delta, target : Node):
	position = lerp(position, Player.position, delta)


func change_direction_x(value):
	direction_x = value

func change_direction_y(value):
	direction_y = value

func reverse_direction_x():
	direction_x *= -1

func reverse_direction_y():
	direction_y *= -1

@export var onCollected_effect_thrownAway = false
var effect_thrownAway_active = false
var rolled_effect_thrownAway_scale = randf_range(0.1, 10)
var effect_thrownAway_scale = Vector2(rolled_effect_thrownAway_scale, rolled_effect_thrownAway_scale)
var effect_thrownAway_rotation = randi_range(-720, 720)
@export var effect_thrownAway_randomize_velocity = true
@export var effect_thrownAway_randomize_velocity_multiplier_x = 1
@export var effect_thrownAway_randomize_velocity_multiplier_y = 1
var effect_thrownAway_velocity = Vector2(randi_range(-1000 * effect_thrownAway_randomize_velocity_multiplier_x, 1000 * effect_thrownAway_randomize_velocity_multiplier_x), randi_range(-500 * effect_thrownAway_randomize_velocity_multiplier_y, -1000 * effect_thrownAway_randomize_velocity_multiplier_y))
var effect_thrownAway_applied_velocity = false

func effect_thrownAway(delta):
	if not effect_thrownAway_active : return
	if not effect_thrownAway_applied_velocity:
		effect_thrownAway_applied_velocity = true
		can_move = false
		velocity = Vector2(effect_thrownAway_velocity)
		only_visual = true
		z_index += 10
		$CollisionShape2D.disabled = true
		if Globals.gameState_debug:
			Globals.display_message("Applying velocity to collected entity.")
	
	sprite.scale.x = lerp(sprite.scale.x, effect_thrownAway_scale[0], delta / 2)
	sprite.scale.y = lerp(sprite.scale.y, effect_thrownAway_scale[1], delta / 2)
	sprite.rotation_degrees = lerp(float(sprite.rotation_degrees), float(effect_thrownAway_rotation), delta)


func handle_award_score():
	Globals.dm(str("An entity is awarding score: %s. Secondary score values: %s, %s, %s." % [score_value, score_value2, score_value3, score_value4, score_value5]))
	
	Globals.level_score += score_value
	
	if Globals.combo_collectibles > 1:
		Globals.combo_score += score_value * Globals.combo_tier
	
	# Combo tier increases every 5 collectibles collected during a combo, usually up to x10, and eventually to x11 after reaching a combo streak of 100.
	if Globals.combo_tier > 1:
		
		pass
		
		if Globals.combo_tier > 2:
			
			pass
			
			if Globals.combo_tier > 3:
				
				pass
				
				if Globals.combo_tier > 4:
					
					sprite.material = Globals.material_rainbow2.duplicate()
					sprite.material.set_shader_parameter("strength", 0.5)
	
	
	else:
		sprite.material.set_shader_parameter("strength", 0.0)
	
	sfx_manager.sfx_play(Globals.sfx_collect, 1.0, 1 * randf_range(-0.2, 0.2) + (0.2 * (Globals.combo_tier - 1)))
	
	animation_general.play("fadeOut_up")
	
	spawn_display_score(score_value)
	spawn_display_score_bonus(score_value, Globals.combo_tier)
	
	Globals.spawn_scenes(World, Globals.scene_particle_star, Globals.combo_tier, Vector2(0, 0), 4.0)
	
	# Handle visual effect of collecting the 20th collectible in a streak (resulting in a x5 multiplier and other player-related changes).
	if Globals.combo_collectibles == 20:
		var max_multiplier_particle_amount = 50
		while max_multiplier_particle_amount > 0:
			max_multiplier_particle_amount -= 1
			call_deferred("spawn_particle_score", 2)
	
	# Handle double score particles (while a temporary powerup is active).
	if get_node_or_null("$/root/World/player"):
		if not Player.double_score:
			return
		
		var effective_score = score_value * Globals.combo_tier
		var particle_quantity : int
		
		if effective_score < 100:
			spawn_particles(Globals.scene_particle_score, effective_score, Vector2(0, 0), Vector2(1, 1))
		else:
			spawn_particles(Globals.scene_particle_score, 100, Vector2(0, 0), Vector2(1, 1))


func spawn_particles(scene, quantity, offset, scale):
	var particle = scene.instantiate()
	
	particle.position = position + offset
	particle.scale = Vector2(scale, scale)
	
	World.add_child(particle)


#func spawn_item():
	#var item
	#
	#if item_scene is String:
		#item = load(item_scene).instantiate()
	#else:
		#item = item_scene.instantiate()
	#
	#if "velocity" in item:
		#item.position = global_position
		#item.velocity.x = rng.randf_range(item_velSpread, -item_velSpread)
		#item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
		#
		#world.add_child(item)
	#else:
		#spawn_item_static()


func spawn_portal():
	var portal = Globals.scene_portal.instantiate()
	portal.level_id = breakable_advanced_portal_level_id
	portal.particle_quantity = breakable_advanced_portal_particle_quantity
	portal.position = start_pos
	
	World.add_child(portal)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "collect_special":
		Globals.message_debug("Special collectible has been deleted after the collect animation finished.")
		queue_free()


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
		velocity.x += speed / 5 * insideWind_direction_X * insideWind_strength_X * delta


func reassign_player():
	Player = get_tree().get_first_node_in_group("player_root")


func handle_collectable(body): # The main function of the "collectible" entity type. The word "collectable" refers to a MAIN BEHAVIOR type, while "collectible" is (most of the time) the entity TYPE of ones with that main behavior type.
	Globals.dm("Attempting to COLLECT an entity", "LIGHT_GREEN")
	
	collected = true
	Globals.entity_collected.emit()
	
	if award_score:
		handle_award_score()
	
	if majorCollectible_module:
		var value = Globals.score_multiplier * Globals.combo_multiplier
		Globals.collected_majorCollectible_module.emit(value)
	
	if majorCollectible_key:
		var value = Globals.score_multiplier * Globals.combo_multiplier
		Globals.collected_majorCollectible_key.emit(value)
	
	
	if heal_player:
		Globals.player_heal.emit(heal_value)
		
		sfx_manager.sfx_play(Globals.sfx_player_heal, 1.0, 0.0)
		Globals.spawn_scenes(World, Globals.scene_particle_star, Globals.combo_tier, Vector2(0, 0), 4.0)
		Globals.spawn_scenes(World, Globals.scene_particle_feather_multiple, 4, Vector2(0, 0), 4.0)
	
	if inventory_item:
		if get_tree().get_nodes_in_group("inventory_item").size() < 10:
			var item = Globals.scene_inventory_item.instantiate()
			Overlay.HUD.add_child(item)
		
		Overlay.HUD.check_inventory()
		get_tree().call_group("inventory_item", "selected_check")
		
		#get_tree().call_group("in_inventory", "itemOrder_correct")


func handle_hittable(body):
	handle_hit(body.damage_value)


func handle_collidable(body):
	pass


func spawn_display_score(score):
	var instance = Globals.display_score.instantiate()
	
	instance.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	World.add_child(instance)

func spawn_display_score_bonus(score, bonus_score):
	var instance = Globals.display_score_bonus.instantiate()
	
	instance.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	World.add_child(instance)

func handle_hit(target):
	if not immortal:
		handle_damage(target)
	
	if on_hit_gain_movement:
		
		can_move = true
		movement_type = on_hit_gain_movement
	
	if inside_projectile:
		
		if not target.direction_v:
			velocity.y = speed * speed_multiplier_y / 2
			velocity.x = speed * speed_multiplier_x * target.direction
			
		else:
			velocity.y = speed * speed_multiplier_y
		
		handle_effects_hit()

func handle_death():
	if collectable:
		collected = true
		
	add_child(Globals.scene_effect_hit_enemy.instantiate())
	add_child(Globals.scene_particle_star.instantiate())
	add_child(Globals.scene_particle_splash.instantiate())
	add_child(Globals.scene_effect_dust.instantiate())
	
	#await get_tree().create_timer(0.5, false).timeout
	
	Globals.entity_hit.emit()
	
	#if portal_award_score:
		#award_score()
		#
	#if portal_spawn_scene:
		#call_deferred("spawn_collectibles")
		#Globals.boxBroken.emit()
	
	if breakable_advanced_portal_on_death_open:
		
		spawn_portal()
		#call_deferred("spawn_portal")
		
		if breakable_advanced_portal_level_id != "none" and SaveData.get("state_" + str(breakable_advanced_portal_level_id)) == 0:
			SaveData.set(("state_" + str(breakable_advanced_portal_level_id)), -1)
			Globals.save_progress.emit()


func reflect_slope():
	if direction_y:
		
		if get_wall_normal()[0] < 0 and get_wall_normal()[1] < 0: #45deg-left up
			direction_x = -1
			direction_y = 0
		
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] < 0: #45deg-right up
			direction_x = 1
			direction_y = 0
		
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] > 0: #45deg-right down
			direction_x = 1
			direction_y = 0
		
		elif get_wall_normal()[0] < 0 and get_wall_normal()[1] > 0: #45deg-left down
			direction_x = -1
			direction_y = 0
	
	else:
		
		if get_wall_normal()[0] < 0 and get_wall_normal()[1] < 0: #45deg-left up
			direction_x = 0
			direction_y = -1
		
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] < 0: #45deg-right up
			direction_x = 0
			direction_y = -1
		
		elif get_wall_normal()[0] > 0 and get_wall_normal()[1] > 0: #45deg-right down
			direction_x = 0
			direction_y = 1
		
		elif get_wall_normal()[0] < 0 and get_wall_normal()[1] > 0: #45deg-left down
			direction_x = 0
			direction_y = 1

func reflect_straight():
	if on_wall_change_velocity:
		velocity *= on_wall_change_velocity_multiplier
	
	if on_wall_change_speed:
		if variable_speed:
			speed *= on_wall_change_speed_multiplier
	
	if get_wall_normal() == Vector2(0, -1): #bottom
		direction_x = 0
		direction_y = -1
	
	elif get_wall_normal() == Vector2(0, 1): #top
		direction_x = 0
		direction_y = 1
	
	elif get_wall_normal() == Vector2(-1, 0): #right
		Globals.message_debug("An entity " + entity_name + " has STRAIGHT REFLECTED.")
		direction_x = -1
		direction_y = 0
	
	elif get_wall_normal() == Vector2(1, 0): #left
		direction_x = 1
		direction_y = 0


# Breakable logic should later become split into BOUNCABLE and BREAKABLE.
func handle_breakable(target):
	Globals.dm("An entity is handling its BREAKABLE logic.", "ORANGE")
	
	if breakable_requires_velocity_y:
		if Player.velocity.y >= breakable_requires_velocity_y_range[0] and Player.velocity.y <= breakable_requires_velocity_y_range[1]:
			if Input.is_action_pressed("jump"):
				Player.velocity.y = breakable_on_hit_player_velocity_y_jump
				velocity = Vector2(0, 0)
				handle_damage(target.damage_value)
				handle_effects_bounce()
				
				Globals.dm("Player's velocity.y was within the range required by this entity to bounce off of. Adding velocity.a to the player: " + str(breakable_on_hit_player_velocity_y), "YELLOW")
			
			else:
				Player.velocity.y = breakable_on_hit_player_velocity_y
				velocity = Vector2(0, 0)
				handle_damage(target.damage_value)
				handle_effects_bounce()
				
				Globals.dm("Player's velocity.y was within the range required by this entity to bounce off of. Adding velocity.a to the player: " + str(breakable_on_hit_player_velocity_y_jump), "YELLOW")
		
		else:
			Globals.dm(str("Player's velocity.y (%s) was not within the range (%s) required by this entity to bounce off of." % [int(Player.velocity.y), breakable_requires_velocity_y_range]), "YELLOW")


func handle_damage(value):
	health_value -= value
	
	if health_value <= 0:
		handle_death()


func handle_effects_hit():
	sfx_manager.sfx_play(Globals.sfx_mechanical2)
	animation_general.stop()

func handle_effects_death():
	sfx_manager.sfx_play(Globals.sfx_mechanical)
	animation_general.stop()

func handle_effects_bounce():
	sfx_manager.sfx_play(Globals.sfx_player_wall_jump, 1.0, 0.75)
	animation_general.stop()
