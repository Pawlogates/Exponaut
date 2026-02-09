extends entity_basic

# For some reason, declaring these properties in the core entity script causes it all to break (all exported properties are set to null). They will be put there after I figure out what is going on.
# Effect - Thrown Away:
@export var on_collected_effect_thrownAway = false
@export var on_death_effect_thrownAway = false

@export var on_collected_decoration_nodes_effect_thrownAway = false
@export var on_death_decoration_nodes_effect_thrownAway = false

@export var effect_thrownAway_randomize_velocity = true
@export var effect_thrownAway_randomize_velocity_multiplier_x = 1
@export var effect_thrownAway_randomize_velocity_multiplier_y = 1

var effect_thrownAway_active = false
var rolled_effect_thrownAway_scale = randf_range(0.1, 6)
var rolled_effect_thrownAway_scale_to_front = Globals.random_bool(1, 3)
var effect_thrownAway_scale = Vector2(rolled_effect_thrownAway_scale, rolled_effect_thrownAway_scale)
var effect_thrownAway_rotation = randi_range(-720, 720)
var effect_thrownAway_velocity = Vector2(randi_range(-1000 * effect_thrownAway_randomize_velocity_multiplier_x, 1000 * effect_thrownAway_randomize_velocity_multiplier_x), randi_range(-500 * effect_thrownAway_randomize_velocity_multiplier_y, -1000 * effect_thrownAway_randomize_velocity_multiplier_y))
var effect_thrownAway_applied_velocity = false
var number = randi_range(0, 999)

func _ready():
	basic_on_spawn()
	reassign_general()
	reassign_movement_type_id()
	
	if start_animation != "none" : animation_all.play(start_animation)
	
	synchronize_animation()
	
	# Prepare patrolling
	if patrolling:
		collision_patrolling.shape.size = patrolling_vision_size
		collision_patrolling.position = patrolling_vision_pos
		
		c_patrolling_change_direction.wait_time = patrolling_change_direction_cooldown
		c_patrolling_change_direction.start()
	
	else:
		scan_patrolling_vision.monitoring = false
	
	
	if movement_type == "move_y" or movement_type == "move_xy" or movement_type == "follow_player_y" or movement_type == "follow_player_y_if_spotted":
		handle_gravity_in_movement_type = true
	
	
	await get_tree().create_timer(0.5, true).timeout
	
	if reset_puzzle:
		scan_reset_puzzle_coverage.monitorable = true
		scan_reset_puzzle_coverage.monitoring = true
	
	await get_tree().create_timer(0.5, true).timeout
	
	if reset_puzzle:
		scan_reset_puzzle_coverage.monitorable = false
		scan_reset_puzzle_coverage.monitoring = false

func _process(delta):
	handle_movement(delta)
	#if reset_puzzle_delete_node_queued : Globals.spawn_scenes(self, Globals.scene_particle_special2_multiple)
	
	if abs(velocity.x) > 15 : velocity_last_x = velocity.x
	if abs(velocity.y) > 15 : velocity_last_y = velocity.y
	
	if on_death_effect_thrownAway or on_collected_decoration_nodes_effect_thrownAway : effect_thrownAway(delta)
	
	if effect_collected_multiple_active : effect_collected_multiple(delta)
	
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
		delete_entity()
	
	if on_collected_effect_special:
		position = lerp(position, World.player.position + random_position_offset, delta)
	
	
	if is_on_wall():
		wall_normal = get_wall_normal()
		
		# if can_collide:
		# Handle straight surface bounce.
		if not reflect_straight() : reflect_slope()
		
		if not gravity or ignore_gravity:
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
	
	sprite_animation()
	
	if patrolling : handle_patrolling()
	
	if reset_puzzle_line_visible : queue_redraw()


func handle_gravity(delta):
	if effect_thrownAway_active : return
	
	if can_move:
		if can_move_y:
			if not is_on_floor() and not ignore_gravity:
				velocity.y += fall_speed * gravity * gravity_multiplier_y * delta
		
		else:
			velocity.y = 0
		
		if can_move_x:
			pass
		
		else:
			velocity.x = 0
	
	else:
		velocity = Vector2(0, 0)


func _on_scan_visible_screen_entered() -> void:
	basic_on_active()

func _on_scan_visible_screen_exited() -> void:
	basic_on_inactive()


func direction_toward_target_x(target):
	if position.x < target.position.x:
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
	
	# Executes only if the node is a valid one to interact with.
	if not area.is_in_group("player_hitbox") and not area.is_in_group("Entity") : return
	else : Globals.dm(str("Player's Main Hitbox has entered an entity's Main Hitbox (%s, %s)" % [entity_name, entity_type]), "CRIMSON")
	
	var target = area.get_parent()
	
	
	# Assigns an "inside" variable depending on the node that just entered this entity. Used mostly for the pushing movement logic.
	inside_check_enter(target)
	
	# Tries to COLLECT the entity.
	if collectable and not collected and target.can_collect:
		if not rotten or target.family != "Player":
			handle_collectable(target)
	
	if hittable:
		handle_hittable(target)

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
		inside_player_all.append(body)
	
	elif body.is_in_group("Entity"):
		
		inside_entity += 1
		inside_entity_last = body
		inside_entity_all.append(body)
		
		if body.entity_type == "projectile":
			inside_projectile += 1
			inside_projectile_last = body
			inside_projectile_all.append(body)
		
		if body.entity_type == "enemy":
			inside_enemy += 1
			inside_enemy_last = body
			inside_enemy_all.append(body)
		
		if body.entity_type == "box":
			inside_box += 1
			inside_box_last = body
			inside_box_all.append(body)
		
		if body.entity_type == "block":
			inside_block += 1
			inside_block_last = body
			inside_block_all.append(body)
	
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
		inside_player_all.erase(body)
	
	elif body.is_in_group("Entity"):
		
		inside_entity -= 1
		inside_entity_last = body
		inside_entity_all.erase(body)
	
	else:
		return
	
	
	if not inside_player and not inside_entity:
		
		direction_x = 0


var handle_gravity_in_movement_type = false # If true, the gravity is not handled for every movement type, and needs to be called by each movement type's function.

# The entity moves (the function is executed every frame) according to its movement type, and only one is active at a time. (This is unlike the other properties, which synergize with eachother to provide a very vast selection of unique object behaviors).
# Movement types: 0 - "normal", 1 - "move_x", 2 - "move_y", 3 - "move_xy", 4 - "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted".

@onready var movement_function_name = "movement_" + movement_type

func handle_movement(delta):
	#if not handle_gravity_in_movement_type : handle_gravity(delta)
	call(movement_function_name, delta)
	#call("movement_" + str(Globals.l_entity_movement[movement_type_id]), delta)
	handle_gravity(delta) # Also handles every type of "can_move".


# Movement types:

# The entity doesn't move by itself, it just falls down to the ground and can be affected by other entities and the player.
func movement_normal(delta):
	if not dead:
		move_in_direction_x(delta)
	
	else:
		handle_friction(delta)

# The entity always attempts to move horizontally, as it's direction can never be equal to 0.
func movement_move_x(delta):
	if not dead:
		move_in_direction_x(delta)
	
	else:
		handle_friction(delta)
	
	if not dead and not direction_x:
		direction_x = direction_active_x # Active means "last value considered active", which in case of velocity, would be anything except 0 (but in this case its actually everything between -25 and 25).

# Same as above, but vertical.
func movement_move_y(delta):
	if direction_y == 0:
		direction_y = direction_active_y
	
	if not dead:
		move_in_direction_x(delta)
		move_in_direction_y(delta)

# Same as above, but both horizontal and vertical.
func movement_move_xy(delta):
	if direction_x == 0:
		direction_x = direction_active_x
	
	if direction_y == 0:
		direction_y = direction_active_y
	
	if not dead:
		move_in_direction_y(delta)
		move_in_direction_x(delta)

# Entity moves horizontally, towards the player.
func movement_follow_player_x(delta):
	if can_turn:
		if position.x < Player.position.x:
			direction_x = 1
		else:
			direction_x = -1
	
	if not dead:
		move_in_direction_x(delta)

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


func movement_follow_player_x_if_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		direction_toward_target_x(Player)
		move_in_direction_x(delta)
	
	else:
		handle_friction(delta)

func movement_follow_player_y_if_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		movement_follow_player_y(delta)

func movement_follow_player_xy_if_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		movement_follow_player_xy(delta)


# Entity will "chase" the player, which means rapidly closing the distance between them, no matter the gap length.
func movement_chase_player_x(delta):
	if not dead:
		chase_target_x(delta, Player)


func movement_chase_player_y(delta):
	if not dead:
		chase_target_y(delta, Player)


func movement_chase_player_xy(delta):
	if not dead:
		chase_target_xy(delta, Player)


func movement_chase_player_x_if_spotted(delta):
	if patrolling_target_spotted_active:
		movement_chase_player_x(delta)


func movement_chase_player_y_if_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		movement_chase_player_y(delta)


func movement_chase_player_xy_if_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		movement_chase_player_xy(delta)


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


var w_target_velocity_y = 100

func movement_wave_y(delta):
	if not dead:
		if velocity.y in range(direction_y * w_target_velocity_y,direction_y * w_target_velocity_y * 100):
			
			direction_y *= -1
	
	velocity.y = move_toward(velocity.y, w_target_velocity_y, delta * speed * speed_multiplier_y)
	
	if not dead:
		movement_move_x(delta)


#"move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted"
func move_around_startPosition_x(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)

func move_around_startPosition_y(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)
		movement_move_y(delta)

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


func move_around_startPosition_x_if_not_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		move_around_startPosition_x(delta)

func move_around_startPosition_y_if_not_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		move_around_startPosition_y(delta)

func move_around_startPosition_xy_if_not_spotted(delta):
	if patrolling_target_spotted_active and not dead:
		move_around_startPosition_x(delta)

# Movement types - [END]


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


#func move_toward_zero_velocity_x(delta):
	#velocity.x = move_toward(velocity.x, 0, delta * friction / 10)
#
#func move_toward_zero_velocity_y(delta):
	#velocity.y = move_toward(velocity.y, 0, delta * friction / 10)

func move_in_direction_x(delta):
	velocity.x = move_toward(velocity.x, direction_x * speed * speed_multiplier_x, delta * acceleration * acceleration_multiplier_x)

func move_in_direction_y(delta):
	velocity.y = move_toward(velocity.y, direction_y * speed * speed_multiplier_y, delta * acceleration * acceleration_multiplier_y)

func chase_target_x(delta, target : Node):
	position.x = lerp(position.x, target.position.x, delta)
	velocity = Vector2(0, 0)

func chase_target_y(delta, target : Node):
	position.y = lerp(position.y, target.position.y, delta)
	velocity = Vector2(0, 0)

func chase_target_xy(delta, target : Node):
	position = lerp(position, target.position, delta)
	velocity = Vector2(0, 0)


func change_direction_x(value):
	direction_x = value

func change_direction_y(value):
	direction_y = value

func reverse_direction_x():
	direction_x *= -1

func reverse_direction_y():
	direction_y *= -1


func effect_thrownAway(delta):
	if not effect_thrownAway_active : return
	
	if not effect_thrownAway_applied_velocity: # This makes the changes apply only on the first frame of the effect being active.
		effect_thrownAway_applied_velocity = true
		
		velocity = effect_thrownAway_velocity
		only_visual = true
		if rolled_effect_thrownAway_scale_to_front : z_index += 10
		else : z_index -= 10
		collision_main.disabled = true
		
		# Correct for potential anim player changes.
		sprite.scale = abs(sprite.scale)
		sprite.skew = rad_to_deg(0)
		
		if not rolled_effect_thrownAway_scale_to_front : effect_thrownAway_scale /= 100 ; Globals.dm("Thrown Away effect's direction has been set to back.", "GREEN")
	
	sprite.scale.x = lerp(sprite.scale.x, effect_thrownAway_scale[0], delta / 2)
	sprite.scale.y = lerp(sprite.scale.y, effect_thrownAway_scale[1], delta / 2)
	sprite.rotation_degrees = lerp(float(sprite.rotation_degrees), float(effect_thrownAway_rotation), delta)
	velocity.y += delta * 1000
	sprite.modulate.a += delta / 10
	if sprite.modulate.a < 0.01 : delete_entity()


func handle_award_score():
	Globals.dm(str("An entity is awarding score: %s. Secondary score values: %s, %s, %s, %s." % [score_value, score_value2, score_value3, score_value4, score_value5]))
	
	Globals.level_score += score_value
	
	if Globals.combo_streak > 1:
		Globals.combo_score += score_value * Globals.combo_tier
	
	# Combo tier increases every 5 collectibles collected during a combo, usually up to x10, and eventually to x11 after reaching a combo streak of 100.
	if Globals.combo_tier > 1:
		
		pass
		
		if Globals.combo_tier > 2:
			
			pass
			
			if Globals.combo_tier > 3:
				
				pass
				
				if Globals.combo_tier > 4:
					
					sprite.material = Globals.material_score_value_rainbow2
					sprite.material.set_shader_parameter("strength", 0.5)
	
	
	else:
		sprite.material = Globals.material_score_value_rainbow2
		sprite.material.set_shader_parameter("strength", 0.0)


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
		delete_entity()


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
	if dead : return
	
	Globals.dm("Attempting to COLLECT an entity", "LIGHT_GREEN")
	
	if reset_puzzle_inside_zone:
		Globals.dm("Updating the list of nodes in an 'reset_puzzle' entity.", 1)
		
		reset_puzzle_master_node.reset_puzzle_nodes_inside_zone.append(self)
		reset_puzzle_delete_node_queued = true
		reset_puzzle_master_node.reset_puzzle_activated.connect(reset_puzzle_delete_entities)
	
	if not collectable_multiple:
		collected = true
		handle_effects_collected()
		
	else:
		if collectable_multiple_health != -1 : collectable_multiple_health -= 1 ; collectable_multiple_health = clamp(collectable_multiple_health, 0, 9999)
		
		if collectable_multiple_health == 0 or collectable_multiple_health < -1:
			collected = true
			handle_effects_collected()
		
		else:
			handle_effects_collected_multiple()
	
	Globals.combo_streak += 1 # These values need to be modified before the "handle_award_score" function goes off, due to many of the visual effects being based on them.
	Globals.entity_collected.emit()
	
	if award_score and on_collected_award_score : handle_award_score()
	
	if reset_puzzle and on_collected_reset_puzzle : handle_reset_puzzle()
	
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
	
	if not reset_puzzle_inside_zone:
		if on_collected_effect_thrownAway : effect_thrownAway_active = true
		
		if on_collected_decoration_nodes_effect_thrownAway:
			for node in container_effect_thrownAway.get_children():
				node.effect_thrownAway_active = true


func handle_hittable(target):
	if dead : return
	
	handle_hit(target.damage_value)
	
	if breakable : handle_breakable(target)


func handle_collidable(body):
	pass


func spawn_display_score(value : int, add_scale : Vector2 = Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))):
	var node = Globals.scene_effect_score_value.instantiate()
	
	node.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	node.value = value
	node.scale += add_scale
	node.z_index += Globals.combo_streak
	
	World.add_child(node)

func spawn_display_score_bonus(value : int, add_scale : Vector2 = Vector2(1, 1), ignore_gravity : bool = false):
	var node = Globals.scene_effect_score_bonus.instantiate()
	
	node.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	node.value = value
	node.add_scale += add_scale # Note: This line modifies a custom property, not "scale".
	node.z_index += Globals.combo_streak
	
	World.add_child(node)


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
	if hittable : dead = true
	if collectable : collected = true
	#if collidable : destroyed = true
	
	if award_score and on_death_award_score: handle_award_score()
	
	direction_x = 0
	direction_y = 0
	
	if on_death_ignore_gravity_stop : ignore_gravity = false
	
	Globals.entity_hit.emit()
	
	hitbox.monitoring = false
	scan_patrolling_vision.monitoring = false
	scan_ledge.enabled = false
	scan_stuck.enabled = false
	
	if breakable_advanced_portal_on_death_open:
		
		spawn_portal()
		
		if breakable_advanced_portal_level_id != "none" and SaveData.get("state_" + str(breakable_advanced_portal_level_id)) == 0:
			SaveData.set(("state_" + str(breakable_advanced_portal_level_id)), -1)
			Globals.save_progress.emit()
	
	handle_effects_death()


func reflect_slope():
	Globals.dm(str("An entity (%s) is Slope Reflecting.") % entity_name)
	
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
	Globals.dm(str("An entity (%s) is Straight Reflecting.") % entity_name)
	
	effects_reflect_straight()
	
	velocity.x = -velocity_last_x
	
	if on_wall_jump_velocity: # If not equal to "0".
		velocity.y = on_wall_jump_velocity
	
	if on_wall_change_velocity:
		velocity *= on_wall_change_velocity_multiplier
	
	if on_wall_change_speed:
		if variable_speed:
			speed *= on_wall_change_speed_multiplier
	
	if get_wall_normal() == Vector2(0, -1): #bottom
		direction_x = 0
		direction_y = -1
		return true
	
	elif get_wall_normal() == Vector2(0, 1): #top
		direction_x = 0
		direction_y = 1
		return true
	
	elif get_wall_normal() == Vector2(-1, 0): #right
		direction_x = -1
		direction_y = 0
		return true
	
	elif get_wall_normal() == Vector2(1, 0): #left
		direction_x = 1
		direction_y = 0
		return true
	
	return false


# Breakable logic should later become split into BOUNCABLE and BREAKABLE.
func handle_breakable(target):
	if not inside_player and target.effect_thrownAway_active : return
	
	Globals.dm("An entity is handling its BREAKABLE logic.", "ORANGE")
	
	if breakable_requires_velocity_y:
		if target.velocity.y >= breakable_requires_velocity_y_range[0] and target.velocity.y <= breakable_requires_velocity_y_range[1]:
			if Input.is_action_pressed("jump"):
				target.velocity.y = breakable_on_hit_player_velocity_y_jump
				handle_damage(target.damage_value)
				if not dead : velocity = Vector2(0, 0)
				handle_effects_bounce()
				
				Globals.dm("Target's velocity.y was within the range required by this entity to bounce off of. Adding velocity.y to the target: " + str(breakable_on_hit_player_velocity_y), "YELLOW", 0.5)
			
			else:
				target.velocity.y = breakable_on_hit_player_velocity_y
				handle_damage(target.damage_value)
				if not dead : velocity = Vector2(0, 0)
				handle_effects_bounce()
				
				Globals.dm("Target's velocity.y was within the range required by this entity to bounce off of. Adding velocity.y to the target: " + str(breakable_on_hit_player_velocity_y_jump), "YELLOW", 0.5)
		
		else:
			Globals.dm(str("Target's velocity.y (%s) was not within the range (%s) required by this entity to bounce off of." % [int(target.velocity.y), breakable_requires_velocity_y_range]), "YELLOW", 0.5)


func handle_damage(value):
	if not immortal : health_value -= value
	
	health_value = clamp(health_value, 0, 9999)
	
	if anim_alternate_walk_hittable_only_during:
		if sprite.animation == "walk_alt":
			health_value -= 10
			sfx_manager.sfx_play(Globals.sfx_powerUp, 1.0, randf_range(0.8, 1.2))
			sfx_manager.sfx_play(Globals.sfx_powerUp2, 1.0, randf_range(0.8, 1.2))
	
	if health_value <= 0:
		handle_death()


func handle_effects_death():
	sfx_manager.sfx_play(sfx_self_death_filepath, 1.0, 0.75)
	
	Globals.spawn_scenes(World, Globals.scene_effect_hit_enemy, 1, position, 4.0)
	Globals.spawn_scenes(World, Globals.scene_particle_star, 1, position, 4.0)
	Globals.spawn_scenes(World, Globals.scene_particle_special2_multiple, 1, position, 4.0)
	Globals.spawn_scenes(World, Globals.scene_particle_special_multiple, 1, position, 4.0)
	Globals.spawn_scenes(World, Globals.scene_effect_dust, 1, position, 4.0)
	
	if on_death_effect_thrownAway : effect_thrownAway_active = true
	if on_death_decoration_nodes_effect_thrownAway:
		for node in container_effect_thrownAway.get_children():
			node.effect_thrownAway_active = true

func handle_effects_hit():
	sfx_manager.sfx_play(Globals.sfx_mechanical2)
	animation_general.stop()
	animation_color.play("pulse_red_normal_long")

func handle_effects_bounce():
	sfx_manager.sfx_play(sfx_self_bounced_filepath, 1.0, 0.75)
	animation_general.stop()
	animation_all.speed_scale = 4.0
	animation_all.play("other_general/air_jumped")


func handle_friction(delta):
	#if direction_x : return
	if effect_thrownAway_active : return
	
	velocity.x = move_toward(velocity.x, 0, delta * 1.5 * friction * friction_multiplier_x)


var walk_alt_loop_number = 0

func _on_sprite_animation_looped():
	if not can_change_sprite_anim : return
	
	if anim_alternate_walk:
		var anim_name = sprite.animation
		Globals.dm(sprite.animation)
		
		if anim_name == "walk":
			walk_alt_loop_number += 1
		
		elif anim_name == "walk_alt":
			sprite.play("walk")
		
		if walk_alt_loop_number >= 5:
			sprite.play("walk_alt")
			walk_alt_loop_number = 0
			
			animation_color.play("pulse_red_normal_slight")


func sprite_animation():
	basic_sprite_flipDirection()
	
	if not can_change_sprite_anim : return
	
	if patrolling:
		if patrolling_target_spotted_active:
			sprite.play("attack")
		else:
			if abs(velocity.x) > 75:
				sprite.play("attack")
			else:
				sprite.play("idle")
		
	elif is_on_floor():
		if velocity.x and sprite.animation == "idle":
			sprite.play("walk")
	
	if dead : sprite.play("dead")


func _on_cooldown_sfx_idle_timeout() -> void:
	sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 1.5), randf_range(0.75, 1.25))
	cooldown_sfx_idle.start()


func effects_reflect_straight():
	animation_general.speed_scale = 2.5
	animation_general.play("reflect_straight")
	sfx_manager.sfx_play(sfx_self_reflected_straight_filepath, 1.0, 0.75)


# Patrolling:
func _on_scan_patrolling_area_entered(area: Area2D) -> void:
	if not patrolling : return
	
	var target = area.get_parent()
	
	for patrolling_target in patrolling_targets:
		
		if target.is_in_group(patrolling_target):
			
			c_patrolling_target_spotted_queue.start()
			
			c_patrolling_target_spotted.stop()
			c_patrolling_change_direction.stop()
			
			break

func _on_scan_patrolling_area_exited(area: Area2D) -> void:
	var target = area.get_parent()
	
	for patrolling_target in patrolling_targets:
		
		if target.is_in_group(patrolling_target):
			
			patrolling_target_spotted_active = false
			
			c_patrolling_change_direction.start()
			
			c_patrolling_target_spotted.stop()
			c_patrolling_target_spotted_queue.stop()
			
			direction_x = 0
			
			break

func _on_cooldown_patrolling_target_spotted_timeout() -> void: # When the entity actually starts following the player.
	patrolling_target_spotted_active = true
	
	c_patrolling_target_spotted.stop()
	c_patrolling_target_spotted_queue.stop()
	c_patrolling_change_direction.stop()

func _on_cooldown_patrolling_target_spotted_queue_timeout() -> void: # When the entity sees the player.
	velocity.y = on_wall_jump_velocity
	Globals.spawn_scenes(self, Globals.scene_particle_star, 5)
	sfx_manager.sfx_play(sfx_spotted_filepath, 1.0, randf_range(0.95, 1.2))
	
	if direction_x : # This check causes repeats less noticable, because the direction is set to "0' on losing sight of the target, and only gets set to active after a timer (patrolling direction) goes off.
		var confusion_text_node = load("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn").instantiate()
		
		confusion_text_node.text_full = "[anim_loop_up_down]!"
		confusion_text_node.cooldown_remove_message = 0.05
		confusion_text_node.character_anim_speed_scale = 8.0
		confusion_text_node.character_anim_backwards = true
		confusion_text_node.text_animation_add_offset = 1.75
		confusion_text_node.scale *= 2
		confusion_text_node.position += Vector2(48 * direction_x, -120)
		
		text_container.add_child(confusion_text_node)
	
	
	c_patrolling_target_spotted.start()
	
	c_patrolling_target_spotted_queue.stop()
	c_patrolling_change_direction.stop()


func handle_patrolling():
	if direction_active_x > 0 : scan_patrolling_vision.scale.x = 1.0
	elif direction_active_x < 0 : scan_patrolling_vision.scale.x = -1.0
	
	if patrolling_target_spotted_active:
		if Globals.random_bool(1, 1):
			sfx_manager.sfx_play(Globals.sfx_footstep_mechanical, 1.0, randf_range(0.75, 1.25))
		else:
			sfx_manager.sfx_play(Globals.sfx_footstep_mechanical2, 1.0, randf_range(0.75, 1.25))

func _on_cooldown_patrolling_change_direction_timeout() -> void:
	
	if direction_x : direction_x *= -1
	else : direction_x = direction_active_x * -1
	
	c_patrolling_change_direction.start()


func handle_effects_collected():
	sfx_manager.sfx_play(sfx_self_collected_filepath, 1.0, randf_range(0.9, 1.1) + (0.025 * (Globals.combo_streak)))
	if on_collected_anim_name != "none" : animation_general.play("fade_out_up")
	
	spawn_display_score(score_value)
	if Globals.combo_streak > 1 : spawn_display_score_bonus(Globals.combo_score, Vector2(-0.9, -0.9) + Vector2((0.05), (0.05)) * Globals.combo_streak)
	elif Globals.debug_mode : spawn_display_score_bonus(Globals.combo_score, -Vector2(-0.5, -0.5))
	
	if on_collected_spawn_star : Globals.spawn_scenes(World, Globals.scene_particle_special, 1 + 1 * Globals.combo_tier, position, 4.0)
	if on_collected_spawn_star2 : Globals.spawn_scenes(World, Globals.scene_particle_star, 1 + 1 * Globals.combo_tier, position, 4.0)
	if on_collected_spawn_orb_orange : Globals.spawn_scenes(World, Globals.scene_particle_special2, 1 + 1 * Globals.combo_tier, position, 4.0)
	if on_collected_spawn_orb_blue : Globals.spawn_scenes(World, Globals.scene_orb_blue, 1 + 1 * Globals.combo_tier, position, 4.0)
	if on_collected_spawn_homing_square_yellow : Globals.spawn_scenes(World, Globals.scene_particle_score, 1 + 1 * Globals.combo_tier, position, 4.0)
	
	# Handle visual effect of collecting the 20th collectible in a streak (resulting in a x5 multiplier and other player-related changes).
	if Globals.combo_streak == 20:
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


func handle_reset_puzzle():
	await reset_puzzle_delete_entities()
	#reset_puzzle_activated.emit()
	
	await get_tree().create_timer(0.5, true).timeout
	
	for entity in reset_puzzle_nodes_inside_zone:
		
		if entity.reset_puzzle_delete_node_queued:
			entity.reset_all()
			Globals.spawn_scenes(Globals.World, Globals.scene_particle_star, 3, position)
			
			sfx_manager.sfx_play([Globals.sfx_powerUp, Globals.sfx_powerUp2].pick_random(), randf_range(0.8, 1.2), randf_range(0.9, 1.1))
		
		else:
			entity.animation_general.play("reflect_straight")
		
		await get_tree().create_timer(0.1, true).timeout
	
	
	Globals.level_score = reset_puzzle_saved_score
	Globals.score_reduced.emit()
	
	reset_puzzle_delete_entities2()


func reset_all():
	call_deferred("spawn_entity_copy")
	
	Globals.dm(str(number))
	Globals.spawn_scenes(Globals.World, Globals.scene_particle_splash, 1, position)


signal reset_puzzle_all_nodes_ready

func spawn_entity_copy():
	var filepath : String = scene_file_path
	var entity = load(filepath).instantiate()
	entity.position = position
	entity.reset_puzzle_inside_zone = reset_puzzle_inside_zone
	entity.reset_puzzle_line_visible = reset_puzzle_line_visible
	entity.reset_puzzle_master_node = reset_puzzle_master_node
	Globals.World.reset_puzzle_line_visible = reset_puzzle_line_visible
	Globals.World.reset_puzzle_line_start = reset_puzzle_master_node.position
	Globals.World.reset_puzzle_line_end = position
	Globals.World.add_child(entity)
	entity.effects_reset()

func effects_reset():
	Globals.dm("An entity (%s, %s) was covered by a 'reset_puzzle' entity. It had just been reset.")
	
	#animation_color.play("pulse_red_normal")
	modulate *= 10
	animation_general.play("reflect_straight")
	sfx_manager.sfx_play(Globals.sfx_beam_enabled)
	Globals.World.reset_puzzle_line_visible = true
	
	await get_tree().create_timer(1.0, true).timeout
	
	Globals.World.reset_puzzle_line_visible = false
	Globals.World.queue_redraw()
	animation_all.play("other_general/scale_downUp")
	
	await get_tree().create_timer(1.0, true).timeout
	modulate = Color(1,1,1,1)
	if start_animation != "none" : animation_all.play(start_animation)


func handle_effects_collected_multiple():
	set_hitbox(false, true)
	
	effect_collected_multiple_active = true
	
	sprite.stop()
	sprite.speed_scale = 1.0
	sprite.play("collected")
	sfx_manager.sfx_play(Globals.sfx_electric_disabled2)
	
	await get_tree().create_timer(1.0 + 0.1 * len(reset_puzzle_nodes_inside_zone), true).timeout
	
	effect_collected_multiple_active = false
	sprite.speed_scale = 1.0
	sprite.play("idle")
	Globals.spawn_scenes(Globals.World, Globals.scene_particle_star, 3, position)
	Globals.spawn_scenes(Globals.World, Globals.scene_particle_special, 6, position)
	
	set_hitbox(true, true)

func effect_collected_multiple(delta):
	sprite.speed_scale += delta
	sprite.play("collected")


func _on_scan_reset_puzzle_coverage_area_entered(area: Area2D) -> void:
	if not reset_puzzle : return
	if not area.is_in_group("scan_always_active") : return
	
	if area.get_parent().is_in_group("entity"):
		var entity = area.get_parent()
		
		Globals.dm("An entity is being assigned to a 'reset_puzzle' entity's zone.")
		
		if not entity.reset_puzzle:
			entity.reset_puzzle_inside_zone = true
			entity.reset_puzzle_master_node = self
			Globals.World.reset_puzzle_line_start = entity.position
			Globals.World.reset_puzzle_line_end = position


func reset_puzzle_delete_entities():
	for entity in reset_puzzle_nodes_inside_zone:
		if entity.reset_puzzle_delete_node_queued : continue
		
		reset_puzzle_nodes_inside_zone.erase(entity)
		entity.delete_entity()

func reset_puzzle_delete_entities2():
	for entity in reset_puzzle_nodes_inside_zone:
		reset_puzzle_nodes_inside_zone.clear()
