extends entity_basic

func _ready():
	#print_stack()
	if delete_on_load : queue_free()
	
	set_hitbox(false)
	scan_visible.visible = true
	
	if entity_type == "box" : c_toggle_hitbox.start()
	else : c_toggle_hitbox.queue_free()
	
	if entity_type == "enemy":
		hittable_if_dead = true
	else:
		hittable_if_dead = false
	
	if sprite_rotation_copy_velocity_x:
		sprite.rotation_degrees = unique_number
	
	if on_spawn_sprite_anim_name_color != "none":
		animation_color.play(on_spawn_sprite_anim_name_color)
	
	if on_spawn_sprite_anim_name_general != "none":
		animation_color.play(on_spawn_sprite_anim_name_general)
	
	if entity_type == "enemy":
		position += Vector2(randi_range(on_spawn_add_position_range[0].x, on_spawn_add_position_range[0].y), randi_range(on_spawn_add_position_range[1].x, on_spawn_add_position_range[1].y))
	
	if Globals.game_state_roguelord:
		z_index = 100
	
	if on_collected_unlock_item_name != "none":
		unlock_item_info = [on_collected_unlock_item_name, on_collected_unlock_item_rarity, on_collected_unlock_item_level, on_collected_unlock_item_durability]
		
		#var item_saved_var_name : String = "qs_item_" + on_collected_unlock_item_name
		#if get(item_saved_var_name) == -1: # If item's level is equal to -1, meaning its not been unlocked.
			#set(item_saved_var_name, 0)
	
	if on_collected_unlock_random_item_weapon:
		var rolled_weapon_name = Globals.qs_list_weapon_name.pick_random()
		
		if Globals.get_random_bool(75) : item_weapon_info = [rolled_weapon_name, randf_range(0.1, 10.0), randi_range(1, 10), 1]
		elif Globals.get_random_bool(75) : item_weapon_info = [rolled_weapon_name, randf_range(0.1, 25.0), randi_range(1, 25), randi_range(1, 2)]
		elif Globals.get_random_bool(75) : item_weapon_info = [rolled_weapon_name, randf_range(0.1, 100.0), randi_range(1, 50), randi_range(1, 3)]
		elif Globals.get_random_bool(75) : item_weapon_info = [rolled_weapon_name, randf_range(0.1, 100.0), randi_range(1, 75), randi_range(1, 4)]
		else: item_weapon_info = [rolled_weapon_name, randf_range(0.1, 100.0), randi_range(1, 200), randi_range(1, 5)]
	
	if item_text_message_copy_weapon_info:
		if item_weapon_info[3] == 1 : text_message = "[anim_loop_up_down]I" ; text_message_visible = "I" ; modulate = Color.WHITE
		elif item_weapon_info[3] == 2 : text_message = "[anim_loop_up_down]II" ; text_message_visible = "II" ; modulate = Color.GREEN_YELLOW
		elif item_weapon_info[3] == 3 : text_message = "[anim_loop_up_down]III" ; text_message_visible = "III" ; modulate = Color.SKY_BLUE
		elif item_weapon_info[3] == 4 : text_message = "[anim_loop_up_down]IV" ; text_message_visible = "IV" ; modulate = Color.MEDIUM_PURPLE
		elif item_weapon_info[3] == 5 : text_message = "[anim_loop_up_down]V" ; text_message_visible = "V" ; modulate = Color.GOLD
	
	if entity_editor_preview:
		add_to_group("entity_editor_preview")
		remove_from_group("persistent")
		remove_from_group("Persist")
		visible = false
		set_hitbox(false)
		return
	
	if always_active : set_hitbox(true)
	
	if start_pos == Vector2(-1, -1) : start_pos = position
	if start_scale == Vector2(-1, -1) : start_scale = scale
	
	if sprite_start_pos == Vector2(-1, -1) : sprite_start_pos = sprite.position
	if sprite_start_scale == Vector2(-1, -1) : sprite_start_scale = sprite.scale
	if sprite_start_modulate == Color(-1, -1, -1, -1) : sprite_start_modulate = sprite.modulate
	
	if effect_grow_target_scale == Vector2(-1, -1):
		effect_grow_target_scale = sprite_start_scale
	
	basic_on_inactive()
	
	if entity_type == "projectile":
		if ignore_gravity : modulate = Color(2, 2, 2, 1)
		else : modulate = Color.WHITE
	
	if on_spawn_effect_grow:
		effect_grow = true
		sprite.scale *= Vector2(0.5, 0.5)
		animation_color.play("pulse_white_short")
	
	if on_spawn_randomize_everything : Globals.spawn_scenes(self, load("res://Objects/entity_randomizator.tscn"))
	
	await get_tree().create_timer(0.05, true).timeout
	
	scan_visible.visible = true
	
	basic_on_spawn()
	reassign_general()
	reassign_movement_type_id()
	
	c_attack_limit.wait_time = cooldown_attack_limit
	
	if general_timers_enabled:
		general_timers_core.t1.wait_time = t1_cooldown + randf_range(-0.1, 0.1)
		general_timers_core.t1.start()
		general_timers_core.t2.wait_time = t2_cooldown + randf_range(-0.1, 0.1)
		general_timers_core.t2.start()
		general_timers_core.t3.wait_time = t3_cooldown + randf_range(-0.1, 0.1)
		general_timers_core.t3.start()
		general_timers_core.t4.wait_time = t4_cooldown + randf_range(-0.1, 0.1)
		general_timers_core.t4.start()
		general_timers_core.t5.wait_time = t5_cooldown + randf_range(-0.1, 0.1)
		general_timers_core.t5.start()
		general_timers_core.t6.wait_time = t6_cooldown + randf_range(-0.1, 0.1)
		general_timers_core.t6.start()
	
	if on_spawn_sfx_death:
		sfx_manager.sfx_play("res://Assets/Sounds/sfx/break.wav", 3.0, 1.0)
	
	if scan_reset_puzzle_coverage_collision_size != Vector2(-1, -1):
		scan_reset_puzzle_coverage_collision.shape.size = scan_reset_puzzle_coverage_collision_size
	
	if on_spawn_copy_direction_x_player:
		if on_spawn_copy_direction_x_active_player:
			direction_x = Globals.player_direction_x_active
		else:
			direction_x = Globals.player_direction_x
	
	if on_spawn_max_speed : velocity.x = direction_x * speed * speed_multiplier_x
	if on_spawn_max_speed : velocity.y = direction_y * speed * speed_multiplier_y
	
	if set_player_attack_cooldown:
		Player.c_attack.wait_time = set_player_attack_cooldown_value
		Player.c_attack.start()
	
	if start_animation != "none" : animation_all.play(start_animation)
	
	synchronize_animation()
	
	if on_death_effect_thrownAway or on_collected_effect_thrownAway:
		
		effect_thrownAway_velocity = Vector2(randi_range(-1000 * effect_thrownAway_randomize_velocity_multiplier_x, 1000 * effect_thrownAway_randomize_velocity_multiplier_x), randi_range(-500 * effect_thrownAway_randomize_velocity_multiplier_y, -1000 * effect_thrownAway_randomize_velocity_multiplier_y))
		
		if on_death_effect_thrownAway_cooldown:
			c_on_death_effect_thrownAway.wait_time = on_death_effect_thrownAway_cooldown
	
	# Prepare patrolling
	if patrolling:
		
		if patrolling_vision_size != Vector2(384, 64): # If not set to default value.
			collision_patrolling.shape.size = patrolling_vision_size
			collision_patrolling.position = patrolling_vision_pos
		
		if is_instance_valid(c_patrolling_change_direction):
			if not patrolling_change_direction_cooldown == -1 : c_patrolling_change_direction.wait_time = patrolling_change_direction_cooldown
			if not patrolling_change_direction_cooldown == -1 : c_patrolling_change_direction.start()
	
	else:
		if is_instance_valid(scan_patrolling_vision):
			scan_patrolling_vision.monitoring = false
	
	
	if movement_type == "move_y" or movement_type == "wave_x" or movement_type == "wave_y" or movement_type == "move_xy" or movement_type == "follow_player_y" or movement_type == "follow_player_y_if_spotted":
		handle_gravity_in_movement_type = true
	
	#await get_tree().create_timer(0.15, true).timeout
	
	if on_spawn_move_delay != 0.0 : await get_tree().create_timer(on_spawn_move_delay, true).timeout
	
	if on_spawn_velocity != Vector2(-1, -1):
		if on_spawn_copy_direction_x_player : velocity = on_spawn_velocity * Vector2(Globals.player_direction_x, 1)
		elif on_spawn_copy_direction_x_active_player : velocity = on_spawn_velocity * Vector2(Globals.player_direction_x_active, 1)
		else : velocity = on_spawn_velocity
	
	if on_spawn_velocity_range != [Vector2(-1, -1), Vector2(-1, -1)]:
		velocity = Vector2(randi_range(-on_spawn_velocity_range[0].x, on_spawn_velocity_range[1].x), randi_range(-on_spawn_velocity_range[0].y, on_spawn_velocity_range[1].y))
	
	block_movement = false
	
	if reset_puzzle:
		if is_instance_valid(scan_reset_puzzle_coverage):
			scan_reset_puzzle_coverage.monitorable = true
			scan_reset_puzzle_coverage.monitoring = true
	
	if is_inside_tree() : await get_tree().create_timer(0.75, true).timeout
	
	is_ready = true
	
	if reset_puzzle:
		reset_puzzle_scan_active = false
	
	if can_move:
		if not reset_puzzle_first_time : await Globals.World.reset_puzzle_all_nodes_ready
		reset_puzzle_queue()
	
	
	if on_spawn_show_text:
		text_show()

@onready var debug_label : Label
@onready var debug_label2 : Label
@onready var debug_label3 : Label
@onready var debug_label4 : Label
@onready var debug_label5 : Label
@onready var debug_label6 : Label
@onready var debug_label7 : Label
@onready var debug_label8 : Label

var attack_melee_block_movement : bool = false


func _process(delta):
	if entity_name == "butterfly" : print("yes")
	#if is_ready : sprite.modulate = Color.BLUE
	#else : sprite.modulate = Color.GREEN
	
	if direction_x : direction_active_x = direction_x
	
	if is_on_floor() : on_floor = true
	else : on_floor = false
	
	if is_on_wall() : on_wall = true
	else : on_wall = false
	
	if entity_editor_preview : return
	
	if sprite_glow_shadow:
		glow_shadow.visible = on_floor # If the entity is on floor, the shadow will be set to visible, otherwise to not visible (because both "on_floor" and "visible" are a boolean).
	
	if dead : sprite.modulate.a = 0.5
	
	if sprite_rainbow_hue_shift:
		if not collected : sprite.material.set_shader_parameter("hue_value", sprite.material.get_shader_parameter("hue_value") + randf_range(-0.001, 0.0015))
	
	if is_instance_valid(scan_ledge):
		if direction_active_x > 0 : scan_ledge.position.x = collision_main.shape.size.x / 2
		elif direction_active_x < 0 : scan_ledge.position.x = -collision_main.shape.size.x / 2
	
	if dead:
		if on_death_rotate_sprite:
			sprite.rotation_degrees = on_death_rotate_sprite
	
	if can_move:
		
		if on_wall and is_collidable:
			set_not_collidable_queue()
			
			wall_normal = get_wall_normal()
		
		if on_floor and is_collidable:
			set_not_collidable_queue()
			
			floor_normal = get_floor_normal()
	
	
	if Globals.debug_mode:
		z_index = 100
		
		if is_instance_valid(debug_label4):
			debug_label.text = "Velocity x/y: " + str(int(velocity_last_x)) + "/" + str(int(velocity_last_y))
			debug_label2.text = "Direction x/y: " + str(direction_x) + "/" + str(direction_y)
			debug_label3.text = "Movement type: " + movement_type
			debug_label4.text = "Entity name: " + entity_name
			debug_label5.text = "Entity hp: " + str(inside_entity)
			debug_label6.text = "Entity hp: " + str(inside_enemy)
			debug_label7.text = "Entity hp: " + str(health_value)
			debug_label8.text = "Entity hp: " + str(health_value)
		
		else:
			var new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 0
			debug_label = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 16
			debug_label2 = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 32
			debug_label3 = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 48
			debug_label4 = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 64
			debug_label5 = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 80
			debug_label6 = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 96
			debug_label7 = new_debug_label
			
			new_debug_label = Label.new()
			add_child(new_debug_label)
			new_debug_label.position.y = 112
			debug_label8 = new_debug_label
	
	else:
		if is_instance_valid(debug_label) : debug_label.queue_free()
		if is_instance_valid(debug_label2) : debug_label2.queue_free()
		if is_instance_valid(debug_label3) : debug_label3.queue_free()
		if is_instance_valid(debug_label4) : debug_label4.queue_free()
		if is_instance_valid(debug_label5) : debug_label5.queue_free()
	
	
	#if dead : modulate.a = move_toward(modulate.a, 0.5, delta / 4)
	#if entity_name == "butterfly" : print(can_move)
	if can_move and not block_movement : handle_movement(delta)
	
	# Handle JUST (1/3):
	just_queue() # The word "just" refers to something very specific. Check out the function for the explanation.
	# Handle JUST (2/3):
	just_update() # The word "just" refers to something very specific. Check out the function for the explanation.
	
	if is_on_ceiling():
		#if ascending:
		if abs(velocity_last_y) > 50:
			velocity.y = -velocity_last_y * 0.85
	
	if copy_direction_x_player:
		if copy_direction_x_active_player:
			direction_x = Globals.player_direction_x_active
		else:
			direction_x = Globals.player_direction_x
	
	if copy_direction_x_player_distance:
		if position.x > Globals.player_position.x : direction_x = -1
		else : direction_x = 1
	
	if look_at_player_rotate:
		rotation_degrees = 0
		look_at(Player.position)
		rotation_degrees += look_at_player_rotate_offset
	
	if removable:
		Globals.message_debug("Removed already collected entity.")
		delete_entity()
	
	
	if can_move:
		if on_wall and is_collidable:
			if on_wall_change_velocity_x:
				if on_wall_change_velocity_value.x != -1:
					velocity.x = on_wall_change_velocity_value.x
					
				velocity.x *= on_wall_change_velocity_multiplier.x
			
			if on_wall_change_velocity_y:
				if on_wall_change_velocity_value.y != -1:
					velocity.y = on_wall_change_velocity_value.y
				
				velocity.y *= on_wall_change_velocity_multiplier.y
			
			
			if on_wall_change_speed:
				if variable_speed:
					speed *= on_wall_change_speed_multiplier
			
			
			if ignore_gravity:
				if reflect_straight or reflect_slope:
					# Handle slope surface bounce
					if not handle_reflect_straight() : handle_reflect_slope()
					
					if direction_y > 0:
						rotation_degrees = 90
					elif direction_y < 0:
						rotation_degrees = -90
	
	if effect_grow:
		sprite.scale.x = move_toward(sprite.scale.x, effect_grow_target_scale.x, delta * 2 * effect_grow_speed_multiplier)
		sprite.scale.y = move_toward(sprite.scale.y, effect_grow_target_scale.y, delta * 2 * effect_grow_speed_multiplier)
		
		if effect_grow and sprite.scale >= effect_grow_target_scale : effect_grow = false
	
	if effect_shrink:
		sprite.scale.x = move_toward(sprite.scale.x, effect_shrink_target_scale.x, delta * effect_shrink_speed_multiplier)
		sprite.scale.y = move_toward(sprite.scale.y, effect_shrink_target_scale.y, delta * effect_shrink_speed_multiplier)
		
		if effect_shrink_delete:
			if sprite.scale.x <= effect_shrink_target_scale.x and sprite.scale.y <= effect_shrink_target_scale.y : delete_entity()
	
	
	if reset_puzzle_line_visible : queue_redraw()
	
	
	if patrolling : handle_patrolling()
	
	if can_move and is_collidable:
		if on_floor : handle_on_floor()
		if on_wall : handle_on_wall()
		
		handle_bounce()
	
	if on_death_effect_thrownAway or on_collected_effect_thrownAway : effect_thrownAway(delta)
	
	if effect_collected_multiple_active : effect_collected_multiple(delta)
	
	if patrolling_anim_while_queued:
		if patrolling_target_spotted_active:
			sprite.play("attack")
		elif velocity.x == 0:
			sprite.play("idle")
	
	else:
		sprite_animation()
	
	if abs(velocity.x) < 100:
		
		if pushable_by_player:
			if inside_player > 0:
				if Player.direction_x:
					velocity.x += Globals.player_direction_x_active * 200
				else:
					velocity.x += Globals.player_direction_x_active * 10
		
		#if pushable_by_entity:
			#if inside_entity > 0 and is_instance_valid(inside_entity_last):
				#var push_direction_x : int = 1
				#if inside_entity_last.position.x > position.x : push_direction_x = -1
				#
				#if abs(inside_entity_last.velocity.x) < 250 and abs(inside_entity_last.velocity.x) > 5:
					#velocity.x += delta * push_direction_x * randf_range(10000, 15000)
				
				#if abs(velocity.x) > abs(inside_entity_last.velocity.x) * 1.1:
					#velocity.x = inside_entity_last.velocity.x * 1.1
	
	handle_inside_entity()
	
	if can_move and not block_movement and not attack_melee_block_movement or effect_thrownAway_active : move_and_slide()
	
	
	# Handle JUST (3/3):
	just_handle()
	
	
	if set_not_collidable:
		is_collidable = false
		set_not_collidable = false # The property is set at the very end of the "_process()" function, because there are multiple events that can affect it, and they would be cancelled otherwise.
	
	if can_move:
		update_velocity_last()
	
	if is_hidden:
		modulate.a = 0.0


func handle_gravity(delta):
	if effect_thrownAway_active : return
	
	if can_move:
		if can_move_y:
			if not on_floor:
				if not ignore_gravity:
					velocity.y += fall_speed * gravity * gravity_multiplier_y * delta
				else:
					if not direction_y:
						velocity.y = move_toward(velocity.y, 0, gravity * gravity_multiplier_y * 100 * delta)
		
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
	if entity_editor_preview : return
	
	# Executes only if the node is a valid one to interact with.
	if not Globals.is_node_valid(area) : return
	else : Globals.dm(str("Player's Main Hitbox has entered an entity's Main Hitbox (%s, %s)" % [entity_name, entity_type]), "CRIMSON")
	
	var target = area.get_parent()
	
	if reset_puzzle_block_movement : return
	if dead : return
	
	# Assigns an "inside" variable depending on the node that just entered this entity. Used mostly for the pushing movement logic.
	if not inside_check_enter(area) : return
	
	# Tries to COLLECT the entity.
	if collectable and not collected and target.can_collect:
		if not rotten or target.family != "Player":
			if target.is_in_group("entity"):
				if not can_move:
					handle_collectable(target)
			
			else:
				handle_collectable(target)
	
	# Tries to HIT the entity.
	#if family == "Player" and target.family == "enemy" or family == "enemy" and target.family == "Player":
	if target.is_in_group("entity") or target.is_in_group("Player"):
		if breakable:
			if handle_breakable(target):
				return
	
	if target.is_in_group("entity"):
		if hittable and damage_from_entity and damage_from_entity_contact:
			handle_hittable(target)
	
	if target.is_in_group("Player"):
		if hittable and damage_from_player and damage_from_player_contact:
			handle_hittable(target)
		
		# THIS SECTION IS A HACK AND SHOULD BE REPLACED ASAP
		if family == "enemy" or damage_to_player:
			if is_ready and damage_to_player_contact:
				#Overlay.HUD.player_main.player_health.change_health_value(damage_value)
				#Globals.player_damage.emit(-damage_value, self)
				Globals.Player.handle_damage(-damage_value, self)
				state_attacking = true
				t_state_attacking.start()

func _on_hitbox_area_exited(area: Area2D) -> void:
	if entity_editor_preview : return
	
	# Executes only if the node is a valid one to interact with.
	if not Globals.is_node_valid(area) : return
	else : Globals.dm(str("Player's Main Hitbox has entered an entity's Main Hitbox (%s, %s)" % [entity_name, entity_type]), "CRIMSON")
	
	if not inside_check_exit(area) : return
	
	if breakable_advanced_on_touch_modulate != Color(1, 1, 1, 1):
		if inside_player:
			sprite.modulate = breakable_advanced_on_touch_modulate


func reassign_movement_type_id(movement_type_name : String = movement_type):
	movement_type = movement_type_name
	movement_type_id = Globals.l_entity_movement_all.find(movement_type_name)
	movement_function_name = "movement_" + movement_type


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
var set_not_collidable = false

func inside_check_enter(area):
	if not is_ready : return false
	if area.get_parent() == self : return false
	if not Globals.is_node_valid(area) : return false
	
	
	var target : Node
	
	if area.get_parent().is_in_group("Player"):
		target = Player
		
		inside_player += 1
		inside_player_last = target
		inside_player_all.append(target)
	
	elif area.get_parent().is_in_group("entity"):
		target = area.get_parent()
		
		inside_entity += 1
		inside_entity_last = target
		inside_entity_all.append(target)
		
		if target.entity_type == "projectile":
			inside_projectile += 1
			inside_projectile_last = target
			inside_projectile_all.append(target)
		
		elif target.entity_type == "enemy":
			inside_enemy += 1
			inside_enemy_last = target
			inside_enemy_all.append(target)
		
		elif target.entity_type == "box":
			inside_box += 1
			inside_box_last = target
			inside_box_all.append(target)
		
		elif target.entity_type == "block":
			inside_block += 1
			inside_block_last = target
			inside_block_all.append(target)
	
	else:
		return false
	
	
	if not can_move or collected or dead : return true
	
	if target.is_in_group("Player") and not pushable_by_player : return true
	if target.is_in_group("entity"):
		if not pushable_by_entity: return true
		else:
			if not target.can_move : return false
			if target.dead : return false
			if target.collected : return false
	
	# Single time on being entered:
	if target.is_in_group("entity"):
		if abs(target.velocity.x) >= 100:
			if Globals.get_random_bool(25) : Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 1, Vector2(position.x + randf_range(-4, 4), position.y - 16 + randf_range(-4, 4)), 1, Color(0, 0, 0, -0.75), Vector2(-0.95, -0.95), 10)
			if Globals.get_random_bool(25) : sfx_manager.sfx_play(sfx_self_reflected_straight_filepath, 0.25 * randf_range(0.5, 1.1))
			
			if abs(target.velocity.x) > 300:
				velocity.y = -abs(target.velocity.x) * randf_range(0.1, 0.75)
			elif abs(target.velocity.x) >= 125:
				velocity.x += target.velocity.x * randf_range(0.5, 1.1)
			else:
				velocity.y = -abs(target.velocity.x) * randf_range(0.05, 0.5)
			
			#if target.velocity.x > 0 : velocity.x = clamp(velocity.x, target.velocity.x / 2, target.velocity.x)
			#elif target.velocity.x < 0 : velocity.x = clamp(velocity.x, target.velocity.x, target.velocity.x / 2)
		
		else:
			if Globals.get_random_bool(75) and not (entity_type == "enemy" and target.entity_type == "collectible"):
				velocity.x += target.direction_active_x * randf_range(50.0, 100.0)
				velocity.y += randf_range(-50.0, -100.0)
		
		if velocity.x > 0 : velocity.x = clamp(velocity.x, 0, speed * speed_multiplier_x)
		elif velocity.x < 0 : velocity.x = clamp(velocity.x, -speed * speed_multiplier_x, 0)
		
		if target.direction_y and not target.entity_type == "collectible":
			if abs(velocity.y) < 25:
				velocity.y += target.direction_y * target.velocity.y * 4
				if velocity.y > 0 : velocity.y *= -1
				
				if target.velocity.y > 0 : velocity.y = clamp(velocity.y, velocity.y / 4, direction_y * target.velocity.y * 2)
				elif target.velocity.y < 0 : velocity.y = clamp(velocity.y, direction_y * target.velocity.y * 2, velocity.y / 4)
				
				sfx_manager.sfx_play("res://Assets/Sounds/sfx/collect3.wav")
	
	elif target.is_in_group("Player"):
		
		if Globals.player_direction_x:
			Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 1, Vector2(position.x, position.y - 16), 1, Color(0, 0, 0, 1), Vector2(-1.5, -1.5) + Vector2(0.1, 0.1) * abs(Player.velocity.x / 100), 10)
			
			if abs(Player.velocity.x) > 1800:
				Globals.spawn_scenes(World, Globals.scene_particle_special, 25, position)
				sfx_manager.sfx_play(sfx_self_hit_filepath, 1.0)
			elif abs(Player.velocity.x) > 900:
				Globals.spawn_scenes(World, Globals.scene_particle_special, 10, position)
				sfx_manager.sfx_play(sfx_self_hit_filepath, 0.75)
			elif abs(Player.velocity.x) > 300:
				sfx_manager.sfx_play(sfx_self_hit_filepath, 0.5)
			else:
				sfx_manager.sfx_play(sfx_self_hit_filepath, 0.25)
			
			velocity.y = Player.velocity.y * 1.25 + randf_range(50, -150)
			
			if abs(Player.velocity.x) > 250:
				velocity.x += Player.velocity.x * 1.1 + randf_range(-5, 5)
			else:
				velocity.x += Globals.player_direction_x_active * 250 + randf_range(-5, 5)
		
		else:
			
			if abs(Player.velocity.x) > 250:
				velocity.x += Player.velocity.x * 0.9 + randf_range(-5, 5)
			else:
				velocity.x += Globals.player_direction_x_active * 100 + randf_range(-5, 5)
	
	
	if collidable and is_collidable:
		
		if inside_player > 0:
			Globals.message_debug("Player entered an entity " + "(" + entity_name + ").")
		else:
			Globals.message_debug("An entity " + "(" + target.entity_name + "). has entered another entity " + "(" + entity_name + ").")
		
		if enteredFromAboveAndNotMoving_enable and target.position.y <= position.y and abs(target.velocity.x) < 25:
				
				direction_x = 0
				velocity.y = -300
				#velocity.y = enteredFromAboveAndNotMoving_velocity
		
		elif on_entityEntered_change_direction_copyEntity:
			
			direction_x = target.direction_x
		
		elif on_entityEntered_change_direction_basedOnPosition:
			
			if target.position.x > position.x:
				direction_x = 1
				
			else:
				direction_x = -1
	
	return true


func inside_check_exit(area):
	if area.get_parent() == self : return false
	if not Globals.is_node_valid(area) : return false
	
	var target : Node
	
	if area.get_parent().is_in_group("Player"):
		target = Player
		
		inside_player += -1
		inside_player_last = target
		inside_player_all.append(target)
	
	elif area.get_parent().is_in_group("entity"):
		target = area.get_parent()
		
		inside_entity += -1
		inside_entity_last = target
		inside_entity_all.append(target)
		
		if target.entity_type == "projectile":
			inside_projectile += -1
			inside_projectile_last = target
			inside_projectile_all.append(target)
		
		elif target.entity_type == "enemy":
			inside_enemy += -1
			inside_enemy_last = target
			inside_enemy_all.append(target)
		
		elif target.entity_type == "box":
			inside_box += -1
			inside_box_last = target
			inside_box_all.append(target)
		
		elif target.entity_type == "block":
			inside_block += -1
			inside_block_last = target
			inside_block_all.append(target)
	
	else:
		return false
	
	
	#if not inside_player and not inside_entity:
		#direction_x = 0
	
	return true
	
	if not can_move or collected or dead : return false
	
	if target.is_in_group("Player") and not pushable_by_player : return false
	if target.is_in_group("entity"):
		if not pushable_by_entity: return false
		else:
			if not target.can_move : return false
			if target.dead : return false
			if target.collected : return false
	
	if target.is_in_group("entity"):
		if abs(target.velocity.x) >= 100:
			pass
			#if Globals.get_random_bool(25) : Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 1, Vector2(position.x + randf_range(-4, 4), position.y - 16 + randf_range(-4, 4)), 1, Color(0, 0, 0, -0.75), Vector2(-0.95, -0.95), 10)
			#sfx_manager.sfx_play(sfx_self_hit_filepath, 0.25)
			
			#velocity.x += target.velocity.x * randf_range(0.5, 1.1)
			
			#velocity.y = -abs(velocity.x) * randf_range(0.75, 1.1)
			
			#if target.velocity.x > 0 : velocity.x = clamp(velocity.x, target.velocity.x / 2, target.velocity.x)
			#elif target.velocity.x < 0 : velocity.x = clamp(velocity.x, target.velocity.x, target.velocity.x / 2)
		
		else:
			if Globals.get_random_bool(75):
				pass
				#velocity.x += target.direction_x * 0
		
		#if velocity.x > 0 : velocity.x = clamp(velocity.x, 0, speed * speed_multiplier_x)
		#elif velocity.x < 0 : velocity.x = clamp(velocity.x, -speed * speed_multiplier_x, 0)
		
		#if target.direction_y:
			#if abs(velocity.y) < 25:
				#velocity.y += target.direction_y * target.velocity.y * randf_range(0.9, 1.1)
				#if velocity.y > 0 : velocity.y *= -1
				#
				#if target.velocity.y > 0 : velocity.y = clamp(velocity.y, velocity.y / 4, direction_y * target.velocity.y * 2)
				#elif target.velocity.y < 0 : velocity.y = clamp(velocity.y, direction_y * target.velocity.y * 2, velocity.y / 4)
				#
				#sfx_manager.sfx_play("res://Assets/Sounds/sfx/collect3.wav")
	
	if target.is_in_group("Player"):
		
		if Globals.player_direction_x:
			Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 1, Vector2(position.x, position.y - 16), 1, Color(0, 0, 0, 1), clamp(Vector2(-1.5, -1.5) + Vector2(0.1, 0.1) * abs(Player.velocity.x / 100), 0.05, 4.0), 10)
			
			if abs(Player.velocity.x) > 1800:
				Globals.spawn_scenes(World, Globals.scene_particle_special, 25, position)
				sfx_manager.sfx_play(sfx_self_hit_filepath, 1.0)
			elif abs(Player.velocity.x) > 900:
				Globals.spawn_scenes(World, Globals.scene_particle_special, 10, position)
				sfx_manager.sfx_play(sfx_self_hit_filepath, 0.75)
			elif abs(Player.velocity.x) > 300:
				sfx_manager.sfx_play(sfx_self_hit_filepath, 0.5)
			else:
				sfx_manager.sfx_play(sfx_self_hit_filepath, 0.25)
			
			velocity.y = jump_velocity_y / 4 + randf_range(-0.5, 0.5)
			
			if abs(Player.velocity.x) > 250:
				velocity.x += Player.velocity.x * 1.1 + randf_range(-5, 5)
			else:
				velocity.x += Globals.player_direction_x_active * 250 + randf_range(-5, 5)
		
		else:
			
			if abs(Player.velocity.x) > 250:
				velocity.x += Player.velocity.x * 0.9 + randf_range(-5, 5)
			else:
				velocity.x += Globals.player_direction_x_active * 100 + randf_range(-5, 5)
	
	return true


var handle_gravity_in_movement_type = false # If true, the gravity is not handled for every movement type, and needs to be called by each movement type's function.

# The entity moves (the function is executed every frame) according to its movement type, and only one is active at a time. (This is unlike the other properties, which synergize with eachother to provide a very vast selection of unique object behaviors).
# Movement types: 0 - "normal", 1 - "move_x", 2 - "move_y", 3 - "move_xy", 4 - "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted".

@onready var movement_function_name = "movement_" + movement_type

func handle_movement(delta):
	if entity_name == "orb_zeroScore" : return
	if reset_puzzle_block_movement : return
	call(movement_function_name, delta)
	#call("movement_" + str(Globals.l_entity_movement[movement_type_id]), delta)
	if ascending:
		velocity.y = lerp(velocity.y, float(jump_velocity_y), delta)
	else:
		handle_gravity(delta) # Also handles every type of "can_move".
	
	handle_inside_zone(delta)


# Movement types:

# The entity doesn't move by itself, it just falls down to the ground and can be affected by other entities and the player.
func movement_normal(delta):
	direction_x = 0
	direction_y = 0
	
	move_in_direction_x(delta)

# The entity always attempts to move horizontally, as it's direction can never be equal to 0.
func movement_move_x(delta):
	move_in_direction_x(delta)

# Same as above, but vertical.
func movement_move_y(delta):
	move_in_direction_y(delta)

# Same as above, but both horizontal and vertical.
func movement_move_xy(delta):
	move_in_direction_y(delta)
	move_in_direction_x(delta)

# Entity moves horizontally, towards the player.
func movement_follow_player_x(delta):
	if can_turn:
		if position.x < Player.position.x:
			direction_x = 1
		else:
			direction_x = -1
	
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
	if not dead:
		if patrolling_target_spotted_active:
			direction_toward_target_x(Player)
			move_in_direction_x(delta)
		else:
			move_toward_zero_velocity(delta)

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
# Note (this not is not true anymore...): This movement type (wave_x and wave_y) is best used alongside the "can_move_y" or "can_move_x" being set to false.
@onready var w_target_velocity_y = speed * speed_multiplier_y

func movement_wave_x(delta):
	if not direction_y : direction_y = 1
	
	if not dead:
		if w_target_velocity_y > 0:
			if velocity.y >= w_target_velocity_y or on_floor:
				direction_y *= -1
				w_target_velocity_y *= -1
				#Globals.smo("flipped")
		
		else:
			if velocity.y <= w_target_velocity_y or is_on_ceiling():
				direction_y *= -1
				w_target_velocity_y *= -1
				#Globals.smo("flipped")
	
	#print(w_target_velocity_y, " ", velocity.y)
	
	# Could probably be replaced with "move_in_direction_y()".
	velocity.y = move_toward(velocity.y, w_target_velocity_y * 1.05, delta * speed * speed_multiplier_y * acceleration_multiplier_y)
	move_in_direction_y(delta)
	
	#if dead : direction_x = 0
	movement_move_x(delta)


var w_target_velocity_x = 150

func movement_wave_y(delta):
	if not dead:
		if velocity.x == w_target_velocity_x:
			
			direction_x *= -1
			w_target_velocity_x *= -1
	
	velocity.x = move_toward(velocity.x, w_target_velocity_x, delta * speed * speed_multiplier_x)
	
	if not dead:
		movement_move_x(delta)


#"move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted"
func movement_move_around_startPosition_x(delta):
	if not dead:
		if abs(start_pos.x - position.x) > 100:
			if position.x < start_pos.x:
				direction_x = 1
			else:
				direction_x = -1
		else:
			velocity.x = 0
		
		move_in_direction_x(delta)

func movement_move_around_startPosition_y(delta):
	if not dead:
		if position.x < start_pos.x:
			direction_x = -1
		else:
			direction_x = 1
		
		movement_move_x(delta)
		movement_move_y(delta)

func movement_move_around_startPosition_xy(delta):
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


func movement_move_around_startPosition_x_if_not_spotted(delta):
	if not patrolling_target_spotted_active:
		movement_move_around_startPosition_x(delta)
	else:
		movement_follow_player_x(delta)

func move_around_startPosition_y_if_not_spotted(delta):
	if not patrolling_target_spotted_active:
		movement_move_around_startPosition_y(delta)

func move_around_startPosition_xy_if_not_spotted(delta):
	if not patrolling_target_spotted_active:
		movement_move_around_startPosition_x(delta)

# Movement types - [END]


func reassign_general():
	World = Globals.reassign_general()[0]
	Player = Globals.reassign_general()[1]
	
	gravity = Globals.gravity


func _on_cooldown_collidable_timeout() -> void:
	is_collidable = true
	if sprite.modulate == Color.WHITE : sprite.modulate = sprite_start_modulate


func _on_cooldown_remove_corpse_timeout() -> void:
	var effect_death = Globals.scene_effect_dead_enemy.instantiate()
	effect_death.position = position
	Globals.World.add_child(effect_death)


func move_in_direction_x(delta):
	if dead or force_direction_x_inactive : direction_x = 0
	
	if direction_x:
		if always_max_speed:
			velocity.x = direction_x * speed * speed_multiplier_x
		else:
			velocity.x = move_toward(velocity.x, direction_x * speed * speed_multiplier_x, delta * acceleration * acceleration_multiplier_x)
	
	else:
		move_toward_zero_velocity(delta)

func move_in_direction_y(delta):
	if dead:
		direction_y = 0
		#move_toward_zero_velocity(delta)
	
	if direction_y:
		if always_max_speed:
			velocity.y = direction_y * speed * speed_multiplier_y
		else:
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


#func change_direction_x(value):
	#direction_x = value
#
#func change_direction_y(value):
	#direction_y = value

func change_direction_x(floor_normal : Vector2 = Vector2(0, 0)):
	#Globals.spawn_message_object(str(wall_normal))
	
	if floor_normal == Vector2(0, 0):
		
		if direction_x != 0:
			direction_x *= -1
		
		else:
			direction_active_x *= -1
	
	else:
		if on_wall_sprite_anim_reflect_straight : effects_reflect_straight()
		
		if floor_normal == Vector2(-1, 0): #right
			direction_x = -1
		
		elif floor_normal == Vector2(1, 0): #left
			direction_x = 1
	
	if force_direction_x:
		if not direction_x:
			direction_x = direction_active_x # Active means "last value considered active", which in case of velocity, would be anything except 0 (but in this case its actually everything between -25 and 25).
	
	if force_direction_y:
		if not direction_y:
			direction_y = direction_active_y
	
	if dead : direction_x = 0
	
	if direction_x : direction_active_x = direction_x
	
	velocity.x = -velocity_last_x
	if abs(velocity.x) < 50 : velocity.x = -velocity_last_x * randf_range(1.0, 4.0)
	
	#Globals.spawn_message_object(velocity_last_x)

func change_direction_y(wall_normal : Vector2 = Vector2(0, 0)):
	if wall_normal == Vector2(0, 0):
		direction_y *= -1
	
	else:
		
		if on_wall_sprite_anim_reflect_straight : effects_reflect_straight()
		
		if wall_normal == Vector2(0, -1): #bottom
			direction_y = 1
		
		elif wall_normal == Vector2(0, 1): #top
			direction_y = 1


func reverse_direction_y():
	direction_y *= -1


func effect_thrownAway(delta):
	if not effect_thrownAway_active : return
	
	if not effect_thrownAway_applied_velocity: # This makes the changes apply only on the first frame of the effect being active.
		effect_thrownAway_applied_velocity = true
		
		if entity_type == "enemy" and Globals.Player.direction_x : effect_thrownAway_velocity = Vector2(randi_range(-200 * effect_thrownAway_randomize_velocity_multiplier_x, 1000 * effect_thrownAway_randomize_velocity_multiplier_x) * Globals.player_direction_x_active, randi_range(-500 * effect_thrownAway_randomize_velocity_multiplier_y, -1000 * effect_thrownAway_randomize_velocity_multiplier_y))
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


func spawn_portal():
	var portal = Globals.scene_portal.instantiate()
	
	portal.level_id = breakable_advanced_portal_level_id
	portal.particle_quantity = breakable_advanced_portal_particle_quantity
	portal.position = start_pos
	
	World.add_child(portal)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "collect_special" or anim_name == "rotate_away_up_right":
		Globals.message_debug("Special collectible has been deleted after the collect animation finished.")
		delete_entity()

func handle_inside_zone(delta):
	if inside_wind:
		velocity.x += inside_wind_direction_x * 2.5 * inside_wind_multiplier_x * speed * delta
		velocity.y += inside_wind_direction_y * 2.5 * inside_wind_multiplier_y * speed * delta


func handle_collectable(target : Node): # The main function of the "collectible" entity type. The word "collectable" refers to a MAIN BEHAVIOR type, while "collectible" is (most of the time) the entity TYPE of ones with that main behavior type.
	if dead : return
	if is_friendly(target) : return
	
	Globals.dm("Attempting to COLLECT an entity", "LIGHT_GREEN")
	
	if experience_value:
		if is_instance_valid(Overlay.hud_player_experience):
			Overlay.hud_player_experience.experience_increase(experience_value + (randi_range(0, Globals.player_level * Globals.player_level)) + randi_range(-experience_value * 0.1, experience_value * 0.1))
	
	if on_collected_unlock_item_name != "none":
		Globals.qs_collected_items.append(unlock_item_info)
		Globals.spawn_scenes(Overlay, load("res://Other/Scenes/hint_scroll_down.tscn"), 1, Vector2(960, 900), -1)
	
	if on_collected_unlock_random_item_weapon:
		Globals.qs_collected_items.append(item_weapon_info)
		Globals.spawn_scenes(Overlay, load("res://Other/Scenes/hint_scroll_down.tscn"), 1, Vector2(960, 900), -1)
	
	if on_collected_gain_movement != "none":
		reassign_movement_type_id(on_collected_gain_movement)
	
	if on_collected_block_movement:
		block_movement = true
	
	if on_collected_spawn_entity:
		if Globals.get_random_bool(on_collected_spawn_entity_chance) : spawn_entity(on_collected_spawn_entity_scene_filepath, on_collected_spawn_entity_quantity, on_collected_spawn_entity_add_velocity, on_collected_spawn_entity_add_velocity_range, on_collected_spawn_entity_pos_offset, on_collected_spawn_entity_pos_offset_range)
	if on_collected_spawn_entity2:
		if Globals.get_random_bool(on_collected_spawn_entity2_chance) : spawn_entity(on_collected_spawn_entity2_scene_filepath, on_collected_spawn_entity2_quantity, on_collected_spawn_entity2_add_velocity, on_collected_spawn_entity2_add_velocity_range, on_collected_spawn_entity2_pos_offset, on_collected_spawn_entity2_pos_offset_range)
	if on_collected_spawn_entity3:
		if Globals.get_random_bool(on_collected_spawn_entity3_chance) : spawn_entity(on_collected_spawn_entity3_scene_filepath, on_collected_spawn_entity3_quantity, on_collected_spawn_entity3_add_velocity, on_collected_spawn_entity3_add_velocity_range, on_collected_spawn_entity3_pos_offset, on_collected_spawn_entity3_pos_offset_range)
	
	
	reset_puzzle_queue()
	
	if not collectable_multiple:
		collected = true
		delete_on_load = true
		handle_effects_collected()
		
	else:
		if collectable_multiple_health != -1 : collectable_multiple_health -= 1 ; collectable_multiple_health = clamp(collectable_multiple_health, 0, 9999)
		
		if collectable_multiple_health == 0 or collectable_multiple_health < -1:
			collected = true
			handle_effects_collected()
		
		else:
			handle_effects_collected_multiple()
	
	if not is_in_group("exclude_collected"):
		Globals.level_collected_collectibles += 1
		Globals.total_collected_collectibles += 1
	
	Globals.combo_streak += 1 # These values need to be modified before the "handle_award_score" function goes off, due to many of the visual effects being based on them.
	Globals.entity_collected.emit()
	
	if award_score and on_collected_award_score : handle_award_score()
	
	if reset_puzzle and on_collected_reset_puzzle : handle_reset_puzzle()
	
	if majorCollectible_module:
		var value = Globals.combo_tier
		Globals.collected_majorCollectibles_module += value
	
	if majorCollectible_key:
		var value = Globals.combo_tier
		Globals.level_collected_majorCollectibles_key += value
	
	
	if heal_player:
		Globals.player_heal.emit(heal_value)
		
		sfx_manager.sfx_play(Globals.sfx_player_heal, 1.0, 0.0)
		Globals.spawn_scenes(World, Globals.scene_particle_star, 12, position, 12.0, Color(0, 0, 0, 0), Vector2(0, 0), 5, [], [], Vector2(0, 0), [Vector2(0, 0), Vector2(0, 0)], [Vector2(-8, -64), Vector2(8, 64)], [Vector2(0, 0), Vector2(0, 0)])
		Globals.spawn_scenes(World, Globals.scene_particle_feather_multiple, 4, position, 12.0, Color(0, 0, 0, 0), Vector2(0, 0), 5, [], [], Vector2(0, 0), [Vector2(0, 0), Vector2(0, 0)], [Vector2(-8, -64), Vector2(8, 64)])
	
	#if inventory_item:
		#if get_tree().get_nodes_in_group("inventory_item").size() < 10:
			#var item = Globals.scene_inventory_item.instantiate()
			#Overlay.HUD.add_child(item)
		#
		#Overlay.HUD.check_inventory()
		#get_tree().call_group("inventory_item", "selected_check")
	
	# I NEED TO KNOW WHY THIS CHECK WAS EVER NEEDED
	#if not reset_puzzle_inside_zone:
	if on_collected_effect_thrownAway : effect_thrownAway_active = true
	
	if on_collected_decoration_nodes_effect_thrownAway:
		for node in container_effect_thrownAway.get_children():
			node.effect_thrownAway_active = true


func handle_hittable(target):
	if dead : return
	if is_friendly(target) : return
	
	if family == "Player" and target.family == "enemy" or family == "enemy" and target.family == "Player":
		handle_hit(target)


func handle_collidable(body):
	pass


func spawn_display_score(value : int):
	var node = Globals.scene_effect_score_value.instantiate()
	
	if entity_type == "enemy" or Globals.combo_streak > 15:
		node.position = Vector2(randi_range(-400, 400), randi_range(-100, -400)) + position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	else:
		node.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	node.value = value
	node.scale += Vector2(1, 1) * randf_range(-0.1, 0.1)
	node.z_index += Globals.combo_streak
	
	World.add_child(node)

func spawn_display_combo_score(value : int):
	var node = Globals.scene_effect_combo_score_value.instantiate()
	
	if entity_type == "enemy" or Globals.combo_streak > 25:
		node.position = Vector2(randi_range(-400, 400), randi_range(-100, -400)) + position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	else:
		node.position = position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
	
	node.value = value
	node.scale += Vector2(1, 1) * 0.1 * Globals.combo_tier
	node.z_index += Globals.combo_streak
	
	World.add_child(node)

# The falling number which uses the same scene as the level up effect.
func spawn_display_score_bonus(value : int, add_scale : Vector2 = Vector2(1, 1), ignore_gravity : bool = false):
	var node = Globals.scene_effect_score_bonus.instantiate()
	
	node.position = Player.position
	
	node.value = value
	node.add_scale += add_scale # Note: This line modifies a custom property, not "scale".
	node.z_index += Globals.combo_streak
	
	World.add_child(node)


func handle_hit(target : Node, f_damage_value : int = target.damage_value):
	Globals.entity_hit.emit()
	
	if not immortal:
		handle_damage(f_damage_value, "normal", target)
	
	handle_effects_hit(target, f_damage_value)
	
	if on_hit_block_movement:
		block_movement = true
	
	if on_hit_spawn_entity:
		if Globals.get_random_bool(on_hit_spawn_entity_chance) : spawn_entity(on_hit_spawn_entity_scene_filepath, on_hit_spawn_entity_quantity, on_hit_spawn_entity_add_velocity, on_hit_spawn_entity_add_velocity_range, on_hit_spawn_entity_pos_offset, on_hit_spawn_entity_pos_offset_range)
	if on_hit_spawn_entity2:
		if Globals.get_random_bool(on_hit_spawn_entity2_chance) : spawn_entity(on_hit_spawn_entity2_scene_filepath, on_hit_spawn_entity2_quantity, on_hit_spawn_entity2_add_velocity, on_hit_spawn_entity2_add_velocity_range, on_hit_spawn_entity2_pos_offset, on_hit_spawn_entity2_pos_offset_range)
	if on_hit_spawn_entity3:
		if Globals.get_random_bool(on_hit_spawn_entity3_chance) : spawn_entity(on_hit_spawn_entity3_scene_filepath, on_hit_spawn_entity3_quantity, on_hit_spawn_entity3_add_velocity, on_hit_spawn_entity3_add_velocity_range, on_hit_spawn_entity3_pos_offset, on_hit_spawn_entity3_pos_offset_range)
	
	
	if on_hit_gain_movement != "none":
		movement_type = on_hit_gain_movement
		reassign_movement_type_id()
		can_move = true
	
	if inside_projectile:
		if on_hit_change_velocity_x_copy_entity:
			velocity.x = target.velocity.x * on_hit_change_velocity_x_copy_entity_multiplier * randf_range(1.05, 0.95)
		elif on_hit_change_velocity_x:
			velocity.x = on_hit_change_velocity_value.x * randf_range(1.05, 0.95)
		
		if on_hit_change_velocity_y_copy_entity:
			velocity.y = -target.velocity.y * on_hit_change_velocity_y_copy_entity_multiplier * 2 * randf_range(1.05, 0.95)
		elif on_hit_change_velocity_y:
			velocity.y = on_hit_change_velocity_value.y * randf_range(1.05, 0.95)
	
	#if on_wall : modulate.r = 10
	#else : modulate.r = 1
	
	if on_wall and abs(velocity_last_x) < 50:
		velocity.x += wall_normal.x * 50
		velocity_last_x += wall_normal.x * 50

func handle_death(type : String = "normal"):
	if entity_editor_preview : return
	if dead : return
	
	dead = true
	delete_on_load = true
	if collectable : collected = true
	#if collidable : destroyed = true
	
	friction *= 4
	
	#if entity_type == "box" : can_move = false
	
	if on_death_rotate_sprite : sprite.rotation_degrees = on_death_rotate_sprite
	
	if on_death_block_movement:
		block_movement = true
	
	if Globals.game_state_roguelord:
		if Globals.get_random_bool(0.1):
			spawn_entity("res://Collectibles/random_item_weapon.tscn", randi_range(1, 3))
	
	if experience_value and entity_type == "enemy":
		if is_instance_valid(Overlay.hud_player_experience):
			Overlay.hud_player_experience.experience_increase(experience_value + (randi_range(0, Globals.player_level * Globals.player_level)) + randi_range(-experience_value * 0.05, experience_value * 0.05))
	
	if award_score and on_death_award_score: handle_award_score()
	
	direction_x = 0
	direction_y = 0
	
	if on_death_spawn_entity:
		if Globals.get_random_bool(on_death_spawn_entity_chance) : spawn_entity(on_death_spawn_entity_scene_filepath, on_death_spawn_entity_quantity, on_death_spawn_entity_add_velocity, on_death_spawn_entity_add_velocity_range, on_death_spawn_entity_pos_offset, on_death_spawn_entity_pos_offset_range)
	if on_death_spawn_entity2:
		if Globals.get_random_bool(on_death_spawn_entity2_chance) : spawn_entity(on_death_spawn_entity2_scene_filepath, on_death_spawn_entity2_quantity, on_death_spawn_entity2_add_velocity, on_death_spawn_entity2_add_velocity_range, on_death_spawn_entity2_pos_offset, on_death_spawn_entity2_pos_offset_range)
	if on_death_spawn_entity3:
		if Globals.get_random_bool(on_death_spawn_entity3_chance) : spawn_entity(on_death_spawn_entity3_scene_filepath, on_death_spawn_entity3_quantity, on_death_spawn_entity3_add_velocity, on_death_spawn_entity3_add_velocity_range, on_death_spawn_entity3_pos_offset, on_death_spawn_entity3_pos_offset_range)
	
	
	if on_death_change_ignore_gravity : ignore_gravity = Globals.opposite_bool(ignore_gravity)
	
	Globals.entity_killed.emit()
	
	if is_instance_valid(hitbox):
		hitbox.monitoring = false
	if is_instance_valid(scan_patrolling_vision):
		scan_patrolling_vision.monitoring = false
	if is_instance_valid(scan_ledge):
		scan_ledge.enabled = false
	if is_instance_valid(scan_stuck):
		scan_stuck.get_child(0).enabled = false
	
	if breakable_advanced_portal_on_death_open:
		
		spawn_portal()
		
		if breakable_advanced_portal_level_id != "none" and SaveData.get("state_" + str(breakable_advanced_portal_level_id)) == 0:
			SaveData.set(("state_" + str(breakable_advanced_portal_level_id)), 0)
			Globals.save_progress.emit()
	
	if override_death_type != "none" : handle_effects_death(override_death_type)
	else : handle_effects_death(type)
	
	if is_instance_valid(master_node):
		if master_node != self:
			master_node.block_spawn_entity = false
	
	
	if on_death_delete_instantly : handle_delete_instantly()


func handle_reflect_slope():
	if not reflect_slope : return
	
	Globals.dm(str("An entity (%s) is Slope Reflecting.") % entity_name)
	
	if direction_y:
		
		if wall_normal[0] < 0 and wall_normal[1] < 0: #45deg-left up
			direction_x = -1
			direction_y = 0
		
		elif wall_normal[0] > 0 and wall_normal[1] < 0: #45deg-right up
			direction_x = 1
			direction_y = 0
		
		elif wall_normal[0] > 0 and wall_normal[1] > 0: #45deg-right down
			direction_x = 1
			direction_y = 0
		
		elif wall_normal[0] < 0 and wall_normal[1] > 0: #45deg-left down
			direction_x = -1
			direction_y = 0
	
	else:
		
		if wall_normal[0] < 0 and wall_normal[1] < 0: #45deg-left up
			direction_x = 0
			direction_y = -1
		
		elif wall_normal[0] > 0 and wall_normal[1] < 0: #45deg-right up
			direction_x = 0
			direction_y = -1
		
		elif wall_normal[0] > 0 and wall_normal[1] > 0: #45deg-right down
			direction_x = 0
			direction_y = 1
		
		elif wall_normal[0] < 0 and wall_normal[1] > 0: #45deg-left down
			direction_x = 0
			direction_y = 1

func handle_reflect_straight():
	if not reflect_straight : return
	
	Globals.dm(str("An entity (%s) is Straight Reflecting.") % entity_name)
	
	effects_reflect_straight()
	
	if wall_normal == Vector2(0, -1): #bottom
		direction_x = 0
		direction_y = -1
		return true
	
	elif wall_normal == Vector2(0, 1): #top
		direction_x = 0
		direction_y = 1
		return true
	
	elif wall_normal == Vector2(-1, 0): #right
		direction_x = -1
		direction_y = 0
		return true
	
	elif wall_normal == Vector2(1, 0): #left
		direction_x = 1
		direction_y = 0
		return true
	
	return false


# Breakable logic should later become split into BOUNCABLE and BREAKABLE.
func handle_breakable(target):
	#if not inside_player and target.effect_thrownAway_active : return
	
	if invulnerable : return
	
	Globals.dm("An entity is handling its BREAKABLE logic.", "ORANGE")
	#Globals.spawn_message_object(str(int(target.velocity.y)) + " " + str(int(breakable_requires_velocity_y_range[0])) + " " + str(int(breakable_requires_velocity_y_range[1])))
	
	if breakable_requires_velocity_y:
		if target.velocity.y >= breakable_requires_velocity_y_range[0] and target.velocity.y <= breakable_requires_velocity_y_range[1]:
			
			if Input.is_action_pressed("jump"):
				target.velocity.y = breakable_on_hit_player_velocity_y_jump
				if not dead : velocity = Vector2(0, 0)
				handle_effects_bounce_player(target)
				handle_damage(target.damage_value, "break", target)
				
				Globals.dm("Target's velocity.y was within the range required by this entity to bounce off of. Adding velocity.y to the target: " + str(breakable_on_hit_player_velocity_y), "YELLOW", 0.5)
			
			else:
				target.velocity.y = breakable_on_hit_player_velocity_y
				if not dead : velocity = Vector2(0, 0)
				handle_effects_bounce_player(target)
				handle_damage(target.damage_value, "break", target)
				#Globals.spawn_message_object(breakable_on_hit_player_velocity_y)
				Globals.dm("Target's velocity.y was within the range required by this entity to bounce off of. Adding velocity.y to the target: " + str(breakable_on_hit_player_velocity_y_jump), "YELLOW", 0.5)
			
			Player.can_air_jump = true
			Player.can_wall_jump = true
			Player.on_just_bounced()
			
			invulnerable = true
			timer_invulnerable.wait_time = 0.5
			timer_invulnerable.start()
			
			return true
		
		else:
			Globals.dm(str("Target's velocity.y (%s) was not within the range (%s) required by this entity to bounce off of." % [int(target.velocity.y), breakable_requires_velocity_y_range]), "YELLOW", 0.5)
			return false
	
	else:
		return false

func handle_damage(value, type : String = "normal", source : Node = self):
	if not immortal:
		if source.family == "Player":
			if family == "enemy" or damage_from_player:
				if damage_from_player:
					health_value -= value ; health_value = clamp(health_value, 0, 9999)
		
		elif source.family == "enemy":
			if family == "Player" or damage_from_entity:
				if damage_from_entity:
					if entity_type == "box":
						health_value -= value * 4 ; health_value = clamp(health_value, 0, 9999)
					else:
						health_value -= value ; health_value = clamp(health_value, 0, 9999)
	
	#print(value, " ", health_value)
	
	state_damage = true
	t_state_damage.start()
	
	if on_hit_disable_anim:
		animation_all.stop()
		animation_all.play("general/RESET")
		animation_general.stop()
		animation_general.play("RESET")
	
	if anim_alternate_walk_hittable_only_during:
		if sprite.animation == "walk_alt":
			health_value -= 1000
			sfx_manager.sfx_play(Globals.sfx_powerUp, 1.0, randf_range(0.8, 1.2))
			sfx_manager.sfx_play(Globals.sfx_powerUp2, 1.0, randf_range(0.8, 1.2))
	
	if health_value <= 0:
		handle_death(type)
	
	if Globals.get_random_bool(100 - Globals.combo_streak * 25) and abs(Globals.Player.camera.rotation_degrees) < 0.25:
		if not dead and not collected and source != self and source.is_in_group("player_projectile"):
			Globals.Player.camera.effect((position - Globals.player_position) * 2, Vector2(1.5, 1.5), randi_range(-7, 7), 4)
			await get_tree().create_timer(0.2, true).timeout
			Globals.Player.camera.effect(Vector2(0, 0), Vector2(1, 1), 0, 1)


func handle_effects_death(type : String = "normal"): # Death types: "normal", "break", "self_destruct", "self_destruct_timed", "crush", "burn", "electrocute".
	if type == "normal" : effect_death_normal()
	elif type == "instant" : effect_death_instant()
	elif type == "break" : effect_death_break()
	elif type == "self_destruct" : effect_death_self_destruct()
	elif type == "self_destruct_timed" : effect_death_self_destruct_timed()
	elif type == "crush" : effect_death_crush()
	elif type == "electrocute" : effect_death_electrocute()
	elif type == "random" : effect_death_random()
	
	if on_death_effect_thrownAway:
		if on_death_effect_thrownAway_cooldown == 0.0:
			effect_thrownAway_active = true
		
		else:
			c_on_death_effect_thrownAway.start()
	
	if on_death_decoration_nodes_effect_thrownAway:
		for node in container_effect_thrownAway.get_children():
			node.effect_thrownAway_active = true
	
	if on_death_effect_shrink:
		effect_shrink = true
		effect_grow = false
	
	animation_all.speed_scale = on_death_anim_speed
	if on_death_anim_name != "none" : animation_all.play(on_death_anim_name)


func effect_death_normal():
	sfx_manager.sfx_play(sfx_self_death_filepath, 1.0, randf_range(0.75, 1.25))
	
	handle_particles_death()

func effect_death_instant():
	sfx_manager.sfx_play(sfx_self_death_filepath, 1.0, randf_range(0.75, 1.25))
	
	handle_particles_death()

func effect_death_break():
	sfx_manager.sfx_play(sfx_self_death_filepath, 2.0, randf_range(0.75, 1.25))
	
	handle_particles_death()
	
	animation_all.stop()
	animation_all.speed_scale = 2.0
	animation_all.play("general/fade_out_up")

func effect_death_self_destruct():
	sfx_manager.sfx_play(sfx_self_death_filepath, 2.0, randf_range(0.75, 1.25))
	
	handle_particles_death()
	
	animation_all.stop()
	animation_all.speed_scale = 2.0
	animation_all.play("general/rotate_away_up_right")

func effect_death_self_destruct_timed():
	pass

func effect_death_crush():
	pass

func effect_death_burn():
	pass

func effect_death_electrocute():
	pass

func effect_death_random():
	sfx_manager.sfx_play(sfx_self_death_filepath, 2.0, randf_range(0.75, 1.25))
	
	handle_particles_death()
	
	animation_all.stop()
	animation_all.speed_scale = 2.0
	animation_all.play(Globals.l_animation_name_all.pick_random())


func handle_effects_hit(target : Node, f_damage_value : int = target.damage_value): # Should be renamed to "handle_effects_hit_self".
	if collected : return
	
	#Globals.spawn_message_object(str(target.family) + " " + (family))
	
	if target.family == "Player" and family == "enemy":
		if damage_from_player:
			sfx_manager.sfx_play(sfx_self_hit_filepath, randf_range(0.5, 1))
			spawn_text_damage(f_damage_value)
		else:
			sfx_manager.sfx_play(sfx_self_hit_filepath, randf_range(0.05, 0.1))
	
	elif target.family == "enemy" and family == "Player":
		if damage_from_entity:
			sfx_manager.sfx_play(sfx_self_hit_filepath, randf_range(0.5, 1))
			spawn_text_damage(f_damage_value)
		else:
			sfx_manager.sfx_play(sfx_self_hit_filepath, randf_range(0.05, 0.1))
	
	if not target.dead:
		state_damage = true
		t_state_damage.start()
	
	animation_color.stop()
	animation_color.play("pulse_red_normal_long")
	
	handle_particles_hit()
	
	sprite.self_modulate.a = 0
	await get_tree().create_timer(0.5, true).timeout
	sprite.self_modulate = sprite_start_modulate

func handle_effects_reflect_self():
	if collected : return
	
	sfx_manager.sfx_play(sfx_self_bounced_filepath, randf_range(0.25, 0.5), 2)
	if Globals.get_random_bool(50) : Globals.spawn_scenes(World, Globals.scene_particle_star, randi_range(1, 3), position, 4, Color.WHITE, Vector2(-0.75, -0.75), 1, ["anim_speed"], [randf_range(4.0, 8.0)])
	
	if sprite.scale == Vector2(1, 1) and not on_death_rotate_sprite:
		animation_all.stop()
		if sprite_rotation_copy_velocity_x : animation_all.speed_scale = 8.0
		else : animation_all.speed_scale = 4.0
		animation_all.play("other_general/air_jumped")


func move_toward_zero_velocity(delta):
	if effect_thrownAway_active : return
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * friction * friction_multiplier_x)
	else:
		velocity.x = move_toward(velocity.x, 0, delta / 12 * friction * friction_multiplier_x)


var walk_alt_loop_number = 0

func _on_sprite_animation_looped():
	if not can_change_sprite_anim : return
	
	if anim_alternate_walk:
		var anim_name = sprite.animation
		
		if anim_name == "walk":
			walk_alt_loop_number += 1
		
		elif anim_name == "walk_alt":
			sprite.play("walk")
			if on_alt_walk_show_text : text_show(on_alt_walk_text_message, on_alt_walk_text_message_visible, on_alt_walk_text_spawn_cooldown, on_alt_walk_text_delete_cooldown, on_alt_walk_text_anim_speed_scale, on_alt_walk_text_anim_backwards, on_alt_walk_text_anim_add_offset, on_alt_walk_text_next_character_cooldown, on_alt_walk_text_add_scale, on_alt_walk_text_add_pos)
		
		if walk_alt_loop_number >= 10:
			sprite.play("walk_alt")
			animation_color.play("pulse_red_normal_slight")
			if on_alt_walk_alt_show_text : text_show(on_alt_walk_alt_text_message, on_alt_walk_alt_text_message_visible, on_alt_walk_alt_text_spawn_cooldown, on_alt_walk_alt_text_delete_cooldown, on_alt_walk_alt_text_anim_speed_scale, on_alt_walk_alt_text_anim_backwards, on_alt_walk_alt_text_anim_add_offset, on_alt_walk_alt_text_next_character_cooldown, on_alt_walk_alt_text_add_scale, on_alt_walk_alt_text_add_pos)
			
			walk_alt_loop_number = 0


func sprite_animation():
	if direction_active_x == 1 : sprite.flip_h = false
	elif direction_active_x == -1 : sprite.flip_h = true
	
	if sprite_anim_speed_copy_velocity_x:
		sprite.speed_scale = clamp(abs(velocity.x / 920), 0, 1)
	
	if sprite_rotation_copy_velocity_x:
		sprite.rotation_degrees += velocity.x / 25
		#if velocity.x > 0:
			#if velocity.x > 25:
				#sprite.rotation_degrees = -velocity.x / 100 + unique_number
			#else:
				#sprite.rotation_degrees = randf_range(-2, 2) + unique_number
		#
		#elif velocity.x < 0:
			#if velocity.x < -25:
				#sprite.rotation_degrees = velocity.x / 100 + unique_number
			#else:
				#sprite.rotation_degrees = randf_range(-2, 2) + unique_number
	
	basic_sprite_flipDirection()
	
	if not can_change_sprite_anim : return
	
	if dead : sprite.play("dead")
	elif state_damage : sprite.play("damage")
	elif state_attacking : sprite.play("attack")
	else:
		if not effect_collected_multiple_active:
			if can_move and on_floor and abs(velocity.x) > 25 : sprite.play("walk")
			elif can_move and ignore_gravity and not on_floor:
				sprite.play("flight")
			else:
				if on_floor:
					sprite.play("idle")
				elif can_move:
					if velocity.y < -400 and not sprite.animation == "jump": sprite.play("jump")
					elif velocity.y > 200 and not sprite.animation == "flight": sprite.play("flight")


func _on_cooldown_sfx_idle_timeout() -> void:
	sfx_manager.sfx_play(Globals.l_sfx_menu_stabilize.pick_random(), randf_range(0.25, 1.5), randf_range(0.75, 1.25))
	cooldown_sfx_idle.start()


func effects_reflect_straight():
	if collected : return
	
	animation_general.stop()
	animation_general.speed_scale = 8
	animation_general.play("reflect_straight")
	sfx_manager.sfx_play(sfx_self_reflected_straight_filepath, randf_range(0.1, 0.25), 0.75)


# Patrolling:
func _on_scan_patrolling_area_entered(area: Area2D) -> void:
	if entity_editor_preview : return
	if not patrolling : return
	#if block_spawn_entity : return
	
	var target = area.get_parent()
	
	for patrolling_target in patrolling_targets:
		
		if target.is_in_group(patrolling_target):
			
			patrolling_target_spotted_queued = true
			
			c_patrolling_target_spotted_queue.start()
			
			c_patrolling_target_spotted.stop()
			c_patrolling_change_direction.stop()
			
			break

func _on_scan_patrolling_area_exited(area: Area2D) -> void:
	if entity_editor_preview : return
	if not patrolling : return
	#if block_spawn_entity : return
	
	var target = area.get_parent()
	
	for patrolling_target in patrolling_targets:
		
		if target.is_in_group(patrolling_target):
			
			patrolling_target_spotted_active = false
			patrolling_target_spotted_queued = false
			
			if not patrolling_change_direction_cooldown == -1 : c_patrolling_change_direction.start()
			
			c_patrolling_target_spotted.stop()
			c_patrolling_target_spotted_queue.stop()
			
			direction_x = 0
			
			break

func _on_cooldown_patrolling_target_spotted_timeout() -> void: # When the entity actually starts following the player.
	patrolling_target_spotted_active = true
	patrolling_target_spotted_queued = false
	
	c_patrolling_target_spotted.stop()
	c_patrolling_target_spotted_queue.stop()
	c_patrolling_change_direction.stop()

func _on_cooldown_patrolling_target_spotted_queue_timeout() -> void: # When the entity sees the player.
	handle_on_spotted()


func handle_patrolling():
	if is_instance_valid(scan_patrolling_vision):
		if direction_active_x > 0 : scan_patrolling_vision.scale.x = 1.0
		elif direction_active_x < 0 : scan_patrolling_vision.scale.x = -1.0
	
	if patrolling_target_spotted_active:
		if Globals.random_bool(19, 1):
			if Globals.random_bool(1, 1):
				sfx_manager.sfx_play(Globals.sfx_footstep_mechanical, 1.0, randf_range(0.75, 1.25))
			else:
				sfx_manager.sfx_play(Globals.sfx_footstep_mechanical2, 1.0, randf_range(0.75, 1.25))

func handle_on_spotted():
	if on_patrolling_spotted_spawn_entity : spawn_entity(on_patrolling_spotted_spawn_entity_scene_filepath, on_patrolling_spotted_spawn_entity_quantity, on_patrolling_spotted_spawn_entity_add_velocity, on_patrolling_spotted_spawn_entity_add_velocity_range, on_patrolling_spotted_spawn_entity_pos_offset, on_patrolling_spotted_spawn_entity_pos_offset_range)
	if on_patrolling_spotted_jump : handle_jump()
	if on_patrolling_spotted_jump_and_move : handle_jump(jump_velocity_y, jump_velocity_x * direction_active_x)
	
	if limit_spawn_entity_repeat : block_spawn_entity = true
	
	if on_floor_change_velocity : velocity.y = on_wall_change_velocity_value.y
	Globals.spawn_scenes(self, Globals.scene_particle_star, 5)
	sfx_manager.sfx_play(sfx_spotted_filepath, 1.0, randf_range(0.95, 1.2))
	
	if direction_x : # This check causes repeats less noticable, because the direction is set to "0' on losing sight of the target, and only gets set to active after a timer (patrolling direction) goes off.
		spawn_message("[anim_loop_up_down]!", 0.5, 8.0, true, 0.0, Vector2(0.25, 0.25), Vector2(64 * direction_x, -64))
	
	
	c_patrolling_target_spotted.start()
	
	c_patrolling_target_spotted_queue.stop()
	c_patrolling_change_direction.stop()


func _on_cooldown_patrolling_change_direction_timeout() -> void:
	if direction_x : direction_x *= -1
	else : direction_x = direction_active_x * -1
	
	if direction_x : direction_active_x = direction_x
	
	if not patrolling_change_direction_cooldown == -1 : c_patrolling_change_direction.start()


func handle_effects_collected():
	text_container.queue_free()
	
	#z_index = 100
	#modulate.r *= 100
	#modulate.g *= 100
	#modulate.b *= 100
	
	if sprite_glow_light:
		sprite_glow_light = false
		glow_light.queue_free()
		
	if sprite_glow_shadow:
		sprite_glow_shadow = false
		glow_shadow.queue_free()
	
	sfx_manager.sfx_play(sfx_self_collected_filepath, 1.0, randf_range(0.9, 1.1) + (0.025 * (Globals.combo_streak)))
	
	animation_all.stop()
	animation_general.stop()
	animation_color.stop()
	animation_all.speed_scale = on_collected_anim_speed
	if on_collected_anim_name != "none" : animation_all.play(on_collected_anim_name)
	
	if award_score and on_collected_award_score:
		spawn_display_score(score_value)
		
		if Globals.combo_streak > 0 : spawn_display_combo_score(score_value * Globals.combo_tier)
		if Globals.combo_streak <= 25 and Globals.combo_streak % 5 == 0 : spawn_display_score_bonus(Globals.combo_score, Vector2(-0.9, -0.9) + Vector2((0.05), (0.05)) * Globals.combo_streak)
	
	handle_particles_collected()
	
	# Handle visual effect of collecting the 20th collectible in a streak (resulting in a x5 multiplier and other player-related changes).
	if Globals.combo_streak == 20:
		var max_multiplier_particle_amount = 50
		while max_multiplier_particle_amount > 0:
			max_multiplier_particle_amount -= 1
			#call_deferred("spawn_particle_score", 2)
	
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
	
	await get_tree().create_timer(0.5, true).timeout
	
	if animation_all.current_animation != on_collected_anim_name:
		animation_all.stop()
		animation_all.speed_scale = on_collected_anim_speed
		if on_collected_anim_name != "none" : animation_all.play(on_collected_anim_name)

func handle_reset_puzzle():
	reset_puzzle_first_time = false
	
	await reset_puzzle_delete_entities()
	
	collectable = false
	hittable = false
	
	for entity in reset_puzzle_nodes_inside_zone:
		if is_instance_valid(entity):
			if entity.reset_puzzle_delete_node_queued and entity.enabled:
				entity.reset_puzzle_block_movement = true
	
	await get_tree().create_timer(0.5, true).timeout
	
	sfx_manager.sfx_play(Globals.sfx_beam_enabled)
	
	if len(reset_puzzle_nodes_inside_zone):
		Globals.Player.camera.enabled = false
		Globals.World.camera.enabled = true
	
	for entity in reset_puzzle_nodes_inside_zone:
		
		if not is_instance_valid(entity) : continue
		
		if entity.enabled:
			if entity.reset_puzzle_delete_node_queued:
				entity.reset_all()
				Globals.spawn_scenes(Globals.World, Globals.scene_particle_star, 3, position)
				
				Globals.World.camera.position = entity.start_pos
			
			else:
				entity.animation_general.play("reflect_straight")
			
			if is_instance_valid(self) : await get_tree().create_timer(clamp(0.5 / (len(reset_puzzle_nodes_inside_zone) / 10), 0.05, 0.5), true).timeout
	
	Globals.Player.camera.enabled = true
	Globals.World.camera.enabled = false
	
	Globals.level_score = clamp(reset_puzzle_saved_score, 0, 9999999)
	Globals.combo_score = 0
	Globals.score_reduced.emit()
	
	reset_puzzle_delete_entities2()
	
	Globals.reset_puzzle_finished.emit()
	
	await get_tree().create_timer(1.0, true).timeout
	
	Globals.World.reset_puzzle_all_nodes_ready.emit()
	
	await get_tree().create_timer(2.0, true).timeout
	
	collectable = true
	hittable = true

func reset_all():
	call_deferred("spawn_entity_copy")
	
	Globals.spawn_scenes(Globals.World, Globals.scene_particle_splash, 1, position)

func reset_puzzle_queue():
	if not is_instance_valid(reset_puzzle_master_node) : return
	if not reset_puzzle_inside_zone : return
	if self in reset_puzzle_master_node.reset_puzzle_nodes_inside_zone : return
	
	Globals.dm("Updating the list of nodes in a 'reset_puzzle' entity.", 1)
	
	reset_puzzle_master_node.reset_puzzle_nodes_inside_zone.append(self)
	reset_puzzle_delete_node_queued = true
	reset_puzzle_master_node.reset_puzzle_activated.connect(reset_puzzle_delete_entities)

#signal reset_puzzle_all_nodes_ready

func spawn_entity_copy():
	Globals.level_collected_collectibles -= 1
	Globals.total_collected_collectibles -= 1
	
	var filepath : String = scene_file_path
	var entity = load(filepath).instantiate()
	
	entity.reset_puzzle_restored = true
	entity.reset_puzzle_block_movement = true
	entity.reset_puzzle_first_time = false
	entity.reset_puzzle_inside_zone = reset_puzzle_inside_zone
	entity.reset_puzzle_master_node = reset_puzzle_master_node
	entity.reset_puzzle_line_visible = reset_puzzle_line_visible
	entity.position = start_pos
	
	Globals.World.reset_puzzle_line_visible = reset_puzzle_line_visible
	Globals.World.reset_puzzle_line_start = reset_puzzle_master_node.position
	Globals.World.reset_puzzle_line_end = start_pos
	
	Globals.World.add_child(entity)
	
	entity.effects_reset()
	
	if not entity_editor_preview : queue_free()
	
	return entity

func effects_reset():
	Globals.dm("An entity (%s, %s) was covered by a 'reset_puzzle' entity. It had just been reset.")
	
	#animation_color.play("pulse_red_normal")
	modulate *= 10
	if is_instance_valid(animation_general) : animation_general.play("reflect_straight")
	sfx_manager.sfx_play([Globals.sfx_powerUp, Globals.sfx_powerUp2].pick_random(), randf_range(0.8, 1.2), randf_range(0.9, 1.1))
	Globals.World.reset_puzzle_line_visible = true
	
	await get_tree().create_timer(1.0, true).timeout
	
	Globals.World.reset_puzzle_line_visible = false
	Globals.World.queue_redraw()
	animation_all.play("other_general/scale_downUp")
	
	await get_tree().create_timer(1.0, true).timeout
	modulate = Color(1,1,1,1)
	# THE BELOW TIMER CANNOT HAVE LESS WAIT TIME THAN 1.5 I NEED TO KNOW WHY AT SOME POINT
	# BUT LEAVING IT FOR NOW BECAUSE I LITERALLY CANT NARROW THIS ISSUE DOWN
	await get_tree().create_timer(1.5, true).timeout
	sprite.scale = sprite_start_scale
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
	if entity_editor_preview : return
	
	if area.get_parent().is_in_group("Player"):
		if reset_puzzle_saved_score == -1 : reset_puzzle_saved_score = Globals.level_score
	
	if not reset_puzzle : return
	if not reset_puzzle_scan_active : return
	if not area.is_in_group("scan_always_active") : return
	
	if area.get_parent().is_in_group("entity"):
		
		var entity = area.get_parent()
		
		#if not entity.enabled : return
		
		Globals.dm("An entity is being assigned to a 'reset_puzzle' entity's zone.", 99)
		
		if not entity.reset_puzzle:
			entity.reset_puzzle_inside_zone = true
			entity.reset_puzzle_master_node = self
			Globals.World.reset_puzzle_line_start = entity.position
			Globals.World.reset_puzzle_line_end = position

func reset_puzzle_delete_entities():
	for entity in reset_puzzle_nodes_inside_zone:
		if is_instance_valid(entity):
			if entity.reset_puzzle_delete_node_queued : continue
			
			reset_puzzle_nodes_inside_zone.erase(entity)
			entity.delete_entity()

func reset_puzzle_delete_entities2():
	for entity in reset_puzzle_nodes_inside_zone:
		reset_puzzle_nodes_inside_zone.clear()


func _on_cooldown_death_timeout() -> void:
	handle_death("self_destruct")

func _on_cooldown_change_ignore_gravity_timeout() -> void:
	ignore_gravity = Globals.opposite_bool(ignore_gravity)
	
	if entity_type == "projectile":
		if ignore_gravity : modulate = Color(2, 2, 2, 1)
		else : modulate = Color.WHITE
		
		effects_reflect_straight()


func spawn_entity(scene_filepath : String, quantity : int = 1, add_velocity : Vector2 = Vector2(0, 0), add_velocity_range : Array = [Vector2(0, 0), Vector2(0, 0)], pos_offset : Vector2 = Vector2(0, 0), pos_offset_range : Array = [Vector2(0, 0), Vector2(0, 0)], add_scale : Vector2 = Vector2(0.0, 0.0), add_scale_range : Array = [Vector2(0, 0), Vector2(0, 0)], add_scale_range_keep_equal : bool = true, delay_range : Array = [0.0, 0.0], master_node : Node = self):
	if effect_thrownAway_active : return
	
	if limit_spawn_entity_cooldown:
		if block_spawn_entity : return
		else : c_attack_limit.start()
	
	var spawned_scenes
	
	spawned_scenes = await Globals.spawn_scenes(World, scene_filepath, quantity, position + pos_offset, -1, Color(0, 0, 0, 0), add_scale, 0, [], [], add_velocity, add_velocity_range, pos_offset_range, spawn_entity_add_scale_range, spawn_entity_add_scale_range_keep_equal, 0.0, spawn_entity_delay_range, master_node)
	
	if spawn_entity_family_copy_entity:
		for entity in spawned_scenes:
			entity.family = family
			Globals.dm(str("Spawned entity has copied its master entity's family (%s)." % family), 5)
	
	if spawn_entity_direction_copy_entity:
		for entity in spawned_scenes:
			entity.direction_x = direction_x
			Globals.dm(str("Spawned entity has copied its master entity's direction (%s)." % direction_x), 10)
	
	if spawn_entity_add_z_index:
		for entity in spawned_scenes:
			entity.z_index = spawn_entity_add_z_index
	
	for entity in spawned_scenes:
		entity.modulate.r *= randf_range(0.75, 1.1)
		entity.modulate.g *= randf_range(0.75, 1.1)
		entity.modulate.b *= randf_range(0.75, 1.1)


func handle_bounce():
	# If there is an issue with "velocity_last", it's probably because of "is_collidable" not being true on time.
	if on_floor:
		if abs(velocity_last_y) > 50:
			if on_floor_bounce:
				velocity.y = -velocity_last_y * on_floor_bounce_velocity_multiplier
				if abs(velocity_last_y) > 100 : handle_effects_reflect_self()
	
	if on_wall:
		if abs(velocity_last_x) > 50:
			if on_wall_bounce:
				velocity.x = -velocity_last_x * on_wall_bounce_velocity_multiplier
				if abs(velocity_last_x) > 100 : handle_effects_reflect_self()


func _on_cooldown_on_death_effect_thrownAway_timeout() -> void:
	effect_thrownAway_active = true


func text_show(text_message : String = text_message, text_message_visible : String = text_message_visible, text_spawn_cooldown : float = text_spawn_cooldown, text_delete_cooldown : float = text_delete_cooldown, text_anim_speed_scale : float = text_anim_speed_scale, text_anim_backwards : bool = text_anim_backwards, text_anim_add_offset : float = text_anim_add_offset, text_next_character_cooldown : float = text_next_character_cooldown, text_add_scale : Vector2 = text_add_scale, text_add_pos : Vector2 = text_add_pos):
	var confusion_text_node = load("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn").instantiate()
	
	confusion_text_node.text_full = text_message
	confusion_text_node.text_visible = text_message_visible
	confusion_text_node.cooldown_create_message = text_spawn_cooldown
	confusion_text_node.cooldown_remove_message = text_delete_cooldown
	confusion_text_node.character_anim_speed_scale = text_anim_speed_scale
	confusion_text_node.character_anim_backwards = text_anim_backwards
	confusion_text_node.text_animation_add_offset = text_anim_add_offset
	confusion_text_node.cooldown_next_character = text_next_character_cooldown
	confusion_text_node.scale += text_add_scale
	confusion_text_node.position += Vector2(text_add_pos.x * direction_x, text_add_pos.y)
	
	if is_instance_valid(text_container) : text_container.add_child(confusion_text_node)


func _on_cooldown_jump_timeout() -> void:
	if is_inside_tree() : await get_tree().create_timer(randf_range(0.01, 0.1), true).timeout
	
	if on_floor or can_jump_in_air:
		if on_timeout_jump_velocity == -1 : velocity.y = jump_velocity_y
		else : velocity.y = on_timeout_jump_velocity
	
	c_jump.wait_time = on_timeout_jump_cooldown
	c_jump.start()

func _on_cooldown_spawn_scene_timeout() -> void:
	await get_tree().create_timer(randf_range(0.01, 0.5), true).timeout
	
	if Globals.get_random_bool(on_timeout_spawn_entity_chance) : spawn_entity(on_timeout_spawn_entity_scene_filepath, on_timeout_spawn_entity_quantity, on_timeout_spawn_entity_add_velocity, on_timeout_spawn_entity_add_velocity_range, on_timeout_spawn_entity_pos_offset, on_timeout_spawn_entity_pos_offset_range,)
	
	c_spawn_entity.wait_time = on_timeout_spawn_entity_cooldown
	c_spawn_entity.start()

func _on_cooldown_change_invincible_timeout() -> void:
	await get_tree().create_timer(randf_range(0.01, 0.5), true).timeout
	
	c_change_invincible.wait_time = on_timeout_change_invincible_cooldown
	c_change_invincible.start()

func _on_cooldown_change_direction_x_timeout() -> void:
	await get_tree().create_timer(randf_range(0.01, 0.5), true).timeout
	
	c_change_direction_x.wait_time = on_timeout_change_direction_x_cooldown
	c_change_direction_x.start()


func handle_jump(value_y : int = jump_velocity_y, value_x : int = 0):
	if not can_jump_in_air and not is_on_floor() : return
	
	if value_y : velocity.y = value_y
	if value_x : velocity.x = value_x
	
	sprite.play("jump")


func handle_on_floor():
	if on_floor_change_speed:
		speed_multiplier_x *= on_floor_change_speed_multiplier
		speed_multiplier_y *= on_floor_change_speed_multiplier
	
	if on_floor_change_direction_y:
		change_direction_y(floor_normal)
	
	if on_landed_spawn_entity:
		if just_landed:
			spawn_entity_general("on_landed_spawn_entity")
			
			Player.camera.effect(Vector2(-1, -1), Vector2(1.25, 1.25), randf_range(-3, 3), 1)
			await get_tree().create_timer(0.1, true).timeout
			Player.camera.effect(Vector2(0, 0), Vector2(1, 1), 0, 0.1)
	
	if on_floor_spawn_entity:
		spawn_entity_general("on_floor_spawn_entity")
	
	if on_ledge_turn:
		if is_collidable and not scan_ledge.is_colliding():
			set_not_collidable_queue()
			
			change_direction_x()
			velocity.x = 0
	
	if on_floor_death : handle_death()
	if on_floor_change_direction_x : change_direction_x()
	if on_floor_reverse_velocity_x : velocity.x = -velocity_last_x
	if on_floor_jump : handle_jump()
	if on_floor_jump_and_move : handle_jump(jump_velocity_y, jump_velocity_x * direction_active_x)

func handle_on_wall():
	if on_wall_death : handle_death()
	
	if on_wall_change_direction_x:
		#Globals.spawn_message_object(str(wall_normal))
		change_direction_x(wall_normal)
	else:
		velocity.x = 0


func _on_cooldown_particles_timeout() -> void:
	pass # Replace with function body.


var state_attacking = false
var state_damage = false

func _on_timer_state_attacking_timeout() -> void:
	state_attacking = false

func _on_timer_state_damage_timeout() -> void:
	state_damage = false


# Activated on their respective general timer's timeout.
func t1_trigger() -> void:
	t_trigger(1)
	general_timers_core.t1.start()

func t2_trigger() -> void:
	t_trigger(2)
	general_timers_core.t2.start()

func t3_trigger() -> void:
	t_trigger(3)
	general_timers_core.t3.start()

func t4_trigger() -> void:
	t_trigger(4)
	general_timers_core.t4.start()

func t5_trigger() -> void:
	t_trigger(5)
	general_timers_core.t5.start()

func t6_trigger() -> void:
	t_trigger(6)
	general_timers_core.t6.start()


func t_trigger(id : int = 0):
	# If a general timer times out, the behaviors with matching id will execute.
	
	if t1_on_timeout_randomize_cooldown : general_timers_core.t1.wait_time = randf_range(0.25 * t1_cooldown, 2 * t1_cooldown)
	if t2_on_timeout_randomize_cooldown : general_timers_core.t2.wait_time = randf_range(0.25 * t2_cooldown, 2 * t2_cooldown)
	if t3_on_timeout_randomize_cooldown : general_timers_core.t3.wait_time = randf_range(0.25 * t3_cooldown, 2 * t3_cooldown)
	if t4_on_timeout_randomize_cooldown : general_timers_core.t4.wait_time = randf_range(0.25 * t4_cooldown, 2 * t4_cooldown)
	if t5_on_timeout_randomize_cooldown : general_timers_core.t5.wait_time = randf_range(0.25 * t5_cooldown, 2 * t5_cooldown)
	if t6_on_timeout_randomize_cooldown : general_timers_core.t6.wait_time = randf_range(0.25 * t6_cooldown, 2 * t6_cooldown)
	
	
	if t_trigger_ascend == id:
		ascending = Globals.opposite_bool(ascending)
	
	if t_trigger_change_direction == id:
		change_direction_x()
	
	if t_trigger_jump == id:
		handle_jump()
	
	if t_trigger_jump_and_move == id:
		handle_jump(jump_velocity_y, jump_velocity_x * direction_active_x)
	
	if t_trigger_randomize_speed_and_jump_velocity == id:
		speed = randi_range(0, 1000)
		jump_velocity_x = randi_range(-200, 1200)
		jump_velocity_x = randi_range(-1200, 1200)
	
	
	if t_trigger_spawn_entity == id:
		spawn_entity_general("t_trigger_spawn_entity")
	
	if t_trigger_spawn_entity2 == id:
		spawn_entity_general("t_trigger_spawn_entity2")
	
	if t_trigger_spawn_entity3 == id:
		spawn_entity_general("t_trigger_spawn_entity3")
	
	
	if t_trigger_self_destruct_and_spawn_entity == id:
		spawn_entity_general("t_trigger_spawn_entity")
		handle_death("self_destruct")
	
	if t_trigger_self_destruct_and_spawn_entity2 == id:
		spawn_entity_general("t_trigger_spawn_entity2")
		handle_death("self_destruct")
	
	if t_trigger_self_destruct_and_spawn_entity3 == id:
		spawn_entity_general("t_trigger_spawn_entity3")
		handle_death("self_destruct")


func spawn_entity_general(event_name : String):
	if not Globals.get_random_bool(get(event_name + "_chance")) : return
	spawn_entity(get(event_name + "_scene_filepath"), get(event_name + "_quantity"), get(event_name + "_add_velocity"), get(event_name + "_add_velocity_range"), get(event_name + "_pos_offset"), get(event_name + "_pos_offset_range"))


var on_floor : bool = false
var on_wall : bool = false

var q_just_landed : bool = false
var just_landed : bool = false

func just_queue():
	if not on_floor:
		q_just_landed = true

func just_update():
	if q_just_landed:
		if on_floor:
			just_landed = true
			q_just_landed = false

func just_handle():
	#if just_landed : player_just_landed.emit()
	#if just_bounced : player_just_bounced.emit()
	
	just_landed = false

func on_just_bounced():
	pass


func _on_cooldown_attack_limit_timeout() -> void:
	block_spawn_entity = false


func set_not_collidable_queue():
	set_not_collidable = true
	c_collidable.wait_time = collidable_cooldown
	c_collidable.start()
	
	#update_velocity_last()


func _on_cooldown_change_movement_type_timeout() -> void:
	reassign_movement_type_id(on_timeout_change_movement_type_name)
	c_change_movement_type.wait_time = on_timeout_change_movement_type_cooldown
	c_change_movement_type.start()


func handle_particles_general():
	if Globals.combo_streak <= 3:
		spawn_particles_collected_full()
	
	elif Globals.combo_streak <= 9 and Globals.get_random_bool(33):
		spawn_particles_collected_full()
	
	else:
		spawn_particles_collected()

func spawn_particles_collected_full():
	var particles_add_scale : Vector2 = Vector2(0, 0)
	if scale.x < 1.0 : particles_add_scale = Vector2(-0.5, -0.5)
	
	Globals.spawn_scenes(World, Globals.scene_particle_special, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	Globals.spawn_scenes(World, Globals.scene_particle_star, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	Globals.spawn_scenes(World, Globals.scene_particle_special2, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	Globals.spawn_scenes(World, Globals.scene_orb_blue, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	Globals.spawn_scenes(World, Globals.scene_particle_homing_square, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0, 0, 0, 0), particles_add_scale)

func spawn_particles_collected():
	var particles_add_scale : Vector2 = Vector2(0, 0)
	if scale.x < 1.0 : particles_add_scale = Vector2(-0.5, -0.5)
	
	if Globals.get_random_bool(on_collected_spawn_star_chance) : Globals.spawn_scenes(World, Globals.scene_particle_special, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_collected_spawn_star2_chance) : Globals.spawn_scenes(World, Globals.scene_particle_star, randi_range(1, 1 + 1 * Globals.combo_tier), position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_collected_spawn_orb_orange_chance) : Globals.spawn_scenes(World, Globals.scene_particle_special2, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_collected_spawn_orb_blue_chance) : Globals.spawn_scenes(World, Globals.scene_orb_blue, randi_range(1, 3), position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_collected_spawn_homing_square_chance) : Globals.spawn_scenes(World, Globals.scene_particle_homing_square, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0, 0, 0, 0), particles_add_scale)

func handle_particles_hit():
	var particles_add_scale : Vector2 = Vector2(0, 0)
	if scale.x < 1.0 : particles_add_scale = Vector2(-0.5, -0.5)
	
	if Globals.get_random_bool(on_hit_spawn_star_chance / 4) : Globals.spawn_scenes(World, Globals.scene_particle_special, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_hit_spawn_star2_chance / 4) : Globals.spawn_scenes(World, Globals.scene_particle_star, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_hit_spawn_orb_orange_chance / 4) : Globals.spawn_scenes(World, Globals.scene_particle_special2, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_hit_spawn_orb_blue_chance / 4) : Globals.spawn_scenes(World, Globals.scene_orb_blue, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_hit_spawn_homing_square_chance) : Globals.spawn_scenes(World, Globals.scene_particle_homing_square, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_hit_spawn_oneShot_chance) : Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0.2, 0.2, 0.2, -0.2), particles_add_scale)

func handle_particles_death():
	var particles_add_scale : Vector2 = Vector2(0, 0)
	if scale.x < 1.0 : particles_add_scale = Vector2(-0.5, -0.5)
	
	if Globals.get_random_bool(on_death_spawn_star_chance) : Globals.spawn_scenes(World, Globals.scene_particle_special, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_star2_chance) : Globals.spawn_scenes(World, Globals.scene_particle_star, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_orb_orange_chance) : Globals.spawn_scenes(World, Globals.scene_particle_special2, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_orb_blue_chance) : Globals.spawn_scenes(World, Globals.scene_orb_blue, 1 + 1 * Globals.combo_tier, position, 4.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_homing_square_chance) : Globals.spawn_scenes(World, Globals.scene_particle_homing_square, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_leaf_chance) : Globals.spawn_scenes(World, Globals.scene_particle_leaf, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_leaf2_chance) : Globals.spawn_scenes(World, Globals.scene_particle_leaf2, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0, 0, 0, 0), particles_add_scale)
	if Globals.get_random_bool(on_death_spawn_oneShot_chance) : Globals.spawn_scenes(World, Globals.scene_effect_oneShot_enemy, 1 + 1 * Globals.combo_tier, position, 12.0, Color(0.2, 0.2, 0.2, -0.2), particles_add_scale)

func handle_particles_collected():
	if Globals.combo_streak <= 3:
		spawn_particles_collected_full()
	
	elif Globals.combo_streak <= 9 and Globals.get_random_bool(33):
		spawn_particles_collected_full()
	
	elif Globals.combo_streak > 75:
		spawn_particles_collected_full()
	
	else:
		spawn_particles_collected()


func _on_cooldown_toggle_hitbox_timeout() -> void:
	if not is_ready : return
	
	if not always_active : set_hitbox(Globals.opposite_bool(hitbox.monitoring))
	else : set_hitbox(true)


func is_friendly(target):
	if target.is_in_group("Player") and family == "enemy" and not is_ready : return true # An exception for handling spawned entities for a very short time right after being spawned.
	
	elif target.is_in_group("entity") and target.family == "Player" and family == "enemy" : false
	elif target.is_in_group("entity") and target.family == "entity" and family == "Player" : false
	elif target.is_in_group("Player") and family == "enemy" : false


func _on_timer_invulnerable_timeout() -> void:
	invulnerable = false


func spawn_text_damage(damage_value : int):
	var effect_text : Node2D = load("res://Other/Effects/effect_text.tscn").instantiate()
	effect_text.position = position + Vector2(randi_range(-100, 100), randi_range(-100, 100))
	effect_text.text_message = str(damage_value)
	effect_text.effect_speed = randf_range(1, 2)
	if entity_type == "enemy" : effect_text.scale.x += -0.5 + 0.01 * damage_value
	else : effect_text.scale.x += -0.85 + 0.01 * damage_value
	effect_text.scale.y = effect_text.scale.x
	#if Globals.get_random_bool(50) : effect_text.scale.x *= -1
	effect_text.rotation_degrees = randi_range(-30, 30)
	effect_text.modulate = effect_text.modulate.blend(Color.RED * randf_range(0.1, 1.0))
	World.add_child(effect_text)


func spawn_message(message_text : String = "none", mesage_cooldown_remove_message : float = 2.0, message_character_anim_speed_scale : float = 1.0, message_character_anim_backwards : bool = false, message_text_animation_add_offset : float = 0.0, message_add_scale : Vector2 = Vector2(0, 0), message_add_pos : Vector2 = Vector2(0, 0)):
	var text_manager = load("res://Other/Scenes/User Interface/Text Manager/text_manager.tscn").instantiate()
		
	text_manager.text_full = message_text
	text_manager.cooldown_remove_message = mesage_cooldown_remove_message
	text_manager.character_anim_speed_scale = message_character_anim_speed_scale
	text_manager.character_anim_backwards = message_character_anim_backwards
	text_manager.text_animation_add_offset = message_text_animation_add_offset
	text_manager.scale += message_add_scale
	text_manager.position += message_add_pos
	
	text_container.add_child(text_manager)

func update_velocity_last():
	if abs(velocity.x) > 5.0 : velocity_last_x = velocity.x
	if abs(velocity.y) > 5.0 : velocity_last_y = velocity.y


func kill():
	health_value = 0
	handle_death()


func handle_effects_bounce_player(target : Node): # Should be renamed to "handle_effects_bounce".
	handle_particles_general()
	handle_effects_reflect_self()
	handle_effects_hit(target)
	sfx_manager.sfx_play(sfx_self_bounced_filepath, 1.0, randf_range(0.75, 1.25))


func handle_inside_entity():
	if not is_instance_valid(inside_enemy_last) : return
	
	# Every frame if inside:
	if inside_enemy:
		if entity_type == "collectible":
			if can_move and can_move_x:
				position.x += randf_range(0.01, 0.5) * inside_enemy_last.direction_active_x
				velocity.x += randf_range(0.025, 0.075) * inside_enemy_last.velocity_last_x
				print(inside_enemy_last.velocity_last_x)


func handle_delete_instantly():
	can_move = false
	sprite.visible = false
	sprite.modulate.a = 0
	await get_tree().create_timer(0.25, true).timeout
	set_process(false)
	await get_tree().create_timer(0.25, true).timeout
	set_hitbox(false, true)
	handle_particles_general()
	delete_entity()
