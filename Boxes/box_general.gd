extends CharacterBody2D

@onready var world = $/root/World
@onready var player = $/root/World.player

@onready var break_bonusBox = %break_bonusBox
@onready var animation_player = %AnimationPlayer
@onready var sprite = %AnimatedSprite2D

var scene_hit_effect = preload("res://Particles/hit_effect.tscn")
var scene_dead_effect = preload("res://Particles/dead_effect.tscn")
var scene_particles_star = preload("res://Particles/particles_star.tscn")
var scene_particles_starFast = preload("res://Particles/particles_starFast.tscn")
var scene_particles_special = preload("res://Particles/particles_special.tscn")
var scene_particles_special_multiple = preload("res://Particles/particles_special_multiple.tscn")
var scene_particles_special2_multiple = preload("res://Particles/particles_special2_multiple.tscn")
var scene_particles_water_entered = preload("res://Particles/particles_water_entered.tscn")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var destroyed = false
var start_hp = 1
var onDeath_start_item_amount = 3

var velocity_x_last = 0.0


# Properties
@export var scoreValue = 100
@export var immortal = false
@export var onDeath_reset = false
@export var onDeath_reset_spawn_items_amount = true
@export var hp = 1
@export var damageValue = 1
@export var SPEED = 250.0
@export var GRAVITY_SCALE = 1.0
@export var bounce_min_velocity = 100
@export var bounce_give_velocity = -400
@export var bounceJump_give_velocity = -600
@export var floating = false

@export var onDeath_spawn_items = true
@export var onDeath_item_amount = 3
@export var onDeath_item_scene = preload("res://Collectibles/collectibleOrange.tscn")
@export var onDeath_item_throw_around = true
@export var onDeath_item_spread_position = true

@export var onDeath_rotate_sprite = true
@export var onDeath_play_anim = true
@export var onDeath_play_spriteAnim = false
@export var onDeath_spawn_deadEffect = false
@export var onDeath_disappear_instantly = false
@export var onDeath_toggle_toggleBlocks = false

@export var onHit_toggle_toggleBlocks = false
@export var hit_cooldown = false
@export var hit_cooldown_time = 0.8

@export var onDeath_activate_switch_signal = false
@export var onDeath_switch_signal_ID = 0

@export var can_collect = false

@export var randomize_everything_onSpawn = false

@export var type : String
# Properties end

func _physics_process(delta):
	if not is_on_floor() and not floating:
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	handle_inside_zone(delta)
	
	if velocity.x != 0 and not inside_wind:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	handle_inside_zone(delta)
	
	if is_on_wall():
		velocity.x = -velocity_x_last / 2
	
	elif velocity.x != 0:
		velocity_x_last = velocity.x
	
	if not destroyed and not floating or not onDeath_play_anim:
		move_and_slide()


# BODY ENTERED
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
			return
	
	if not active:
		print("Box entered, but it was inactive.")
		return
	
	if body.is_in_group("player") and not body.get_parent().is_in_group("weightless"):
		if not destroyed:
			if player_bounce(body):
				var value = body.damageValue
				reduce_hp(value)
				
				world.screen_shake()
				
				if hp <= 0:
					destroy()
	
	elif body.is_in_group("player_projectile"):
		if not destroyed:
			var value = body.damageValue
			reduce_hp(value)
			
			if hp <= 0:
				destroy()
	
	elif body.is_in_group("Collectibles") or body.is_in_group("enemies") or body.is_in_group("bonusBox"):
		
		if not destroyed:
			if other_bounce(body):
				var value = body.damageValue
				reduce_hp(value)
				
				if hp <= 0:
					destroy()
	
	#else:
		#print(body.get_groups())

# BODY ENTERED END

# AREA ENTERED
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("special_block"):
		var block = area.get_parent()
		
		if not destroyed:
			if other_bounce(block):
				var value = block.damageValue
				reduce_hp(value)
				
				if hp <= 0:
					destroy()

# AREA ENTERED END


func reduce_hp(value):
	if hit_cooldown:
		active = false
		$active_cooldown.start()
		
		sprite.modulate.a = 0.5
	
	if not immortal:
		hp -= value
	
	onBounce_effect()
	
	if onHit_toggle_toggleBlocks:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")

func destroy():
	if not onDeath_reset:
		destroyed = true
		
		if onDeath_play_spriteAnim:
			if sprite.get_sprite_frames().has_animation("destroyed"):
				sprite.play("destroyed")
		
		if onDeath_play_anim:
			%AnimationPlayer.play("destroyed")
		
		if not onDeath_play_spriteAnim or not sprite.get_sprite_frames().has_animation("destroyed"):
			if not onDeath_play_anim:
				disappear_instantly()
		
		if onDeath_rotate_sprite:
			%sprite_root.rotation_degrees = rng.randf_range(-60.0, 30.0)
		if onDeath_spawn_deadEffect:
			var dead_effect = scene_dead_effect.instantiate()
			add_child(dead_effect)
	else:
		hp = start_hp
		if onDeath_reset_spawn_items_amount:
			onDeath_item_amount = onDeath_start_item_amount
	
	
	if onDeath_toggle_toggleBlocks:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")
	
	if onDeath_activate_switch_signal:
		Globals.switch_signal_activated.emit(onDeath_switch_signal_ID)
	
	if onDeath_spawn_items:
		call_deferred("spawn_items", onDeath_item_amount, onDeath_item_scene)
	
	break_bonusBox.play()
	Globals.boxBroken.emit()
	
	var star = scene_particles_special.instantiate()
	add_child(star)
	var star2 = scene_particles_special.instantiate()
	add_child(star2)
	var star3 = scene_particles_special.instantiate()
	add_child(star3)


func player_bounce(body):
	if body.velocity.y > bounce_min_velocity:
		if Input.is_action_pressed("jump"):
			body.velocity.y = bounceJump_give_velocity
		else:
			body.velocity.y = bounce_give_velocity
		
		body.air_jump = true
		body.wall_jump = true
		
		return true
	
	else:
		return false

func other_bounce(body):
	if body.velocity.y > bounce_min_velocity:
		body.velocity.y = bounceJump_give_velocity
		
		return true
	
	else:
		return false


func spawn_items(item_amount, item_scene):
	while item_amount > 0:
		item_amount -= 1
		spawn_item(item_scene)


var rng = RandomNumberGenerator.new()

func spawn_item(item_scene):
	var item = item_scene.instantiate()
	
	if onDeath_item_throw_around:
		if item.get("velocity") == null:
			return
		item.velocity.x = rng.randf_range(400.0, -400.0)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	if onDeath_item_spread_position:
		item.position = position + Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
	else:
		item.position = position
	
	world.add_child(item)


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
	
	$Area2D.set_monitorable(false)
	$Area2D.set_monitoring(false)

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
	
	await get_tree().create_timer(0.5, false).timeout
	$Area2D.set_monitorable(true)
	$Area2D.set_monitoring(true)

func _ready():
	if randomize_everything_onSpawn:
		randomize_everything()
	
	%AnimatedSprite2D.play("idle")
	if hit_cooldown:
		$active_cooldown.wait_time = hit_cooldown_time
	
	start_hp = hp
	onDeath_start_item_amount = onDeath_item_amount
	
	
	set_process(false)
	set_physics_process(false)
	
	set_process_input(false)
	set_process_internal(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	sprite.pause()
	sprite.visible = false
	animation_player.active = false
	
	$Area2D.set_monitorable(false)
	$Area2D.set_monitoring(false)
	
	await get_tree().create_timer(0.2, false).timeout
	if destroyed:
		queue_free()


#Randomization
func randomize_everything():
	#prepare lists
	list_sprite = prepare_list_all("Assets/Graphics/sprites/packed/boxes", [])
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
	SPEED = randi_range(0, 1200)
	GRAVITY_SCALE = randf_range(-2, 4)
	bounce_min_velocity = randi_range(-500, 500)
	bounce_give_velocity = randi_range(-2000, 1000)
	bounceJump_give_velocity = randi_range(-2000, 750)
	floating = applyRandom_falseTrue(3, 1)
	onDeath_spawn_items = applyRandom_falseTrue(1, 6)
	onDeath_item_amount = randi_range(1, 32)
	onDeath_item_throw_around = applyRandom_falseTrue(2, 1)
	
	if onDeath_item_amount > 1 and not onDeath_item_throw_around:
		onDeath_item_spread_position = true
	else:
		onDeath_item_spread_position = applyRandom_falseTrue(1, 3)
	
	if onDeath_item_amount > 8:
		onDeath_item_scene = load(applyRandom_fromList("list_onDeath_item_blacklist_enemy_scene", -1))
	else:
		onDeath_item_scene = load(applyRandom_fromList("list_onDeath_item_scene", -1))
	
	onDeath_rotate_sprite = applyRandom_falseTrue(1, 2)
	onDeath_play_anim = applyRandom_falseTrue(1, 3)
	onDeath_play_spriteAnim = applyRandom_falseTrue(1, 2)
	onDeath_spawn_deadEffect = applyRandom_falseTrue(1, 4)
	onHit_toggle_toggleBlocks = applyRandom_falseTrue(1, 6)
	onDeath_toggle_toggleBlocks = applyRandom_falseTrue(1, 4)
	hit_cooldown = applyRandom_falseTrue(3, 1)
	hit_cooldown_time = randf_range(0, 4)
	immortal = applyRandom_falseTrue(5, 1)
	onDeath_reset = applyRandom_falseTrue(4, 1)
	onDeath_reset_spawn_items_amount = applyRandom_falseTrue(1, 1)
	hp = randi_range(1, 5)
	damageValue = randi_range(1, 5)
	scoreValue = randi_range(0, 100000)
	
	modulate.r = randf_range(0, 1)
	modulate.g = randf_range(0, 1)
	modulate.b = randf_range(0, 1)
	modulate.a = randf_range(0.75, 1)
	
	sprite.sprite_frames = load(applyRandom_fromList("list_sprite", -1))
	sprite.material.set_shader_parameter("Shift_Hue", randf_range(0, 1))
	if applyRandom_falseTrue(6, 1):
		scale.x = randf_range(0.05, 2)
		scale.y = scale.x
	if applyRandom_falseTrue(4, 1) : sprite.material = null


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
			if not filename.ends_with(".import") and not filename.ends_with(".gd") and not filename.ends_with(".uid"):
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
	var randomized_number = randf_range(-false_probability, true_probability)
	if randomized_number <= 0:
		return false
	else:
		return true


#SAVE START
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"destroyed" : destroyed,
		"hp" : hp,
		"start_hp" : start_hp,
	
	}
	return save_dict
#SAVE END


var active = true

func _on_active_cooldown_timeout():
	active = true
	
	sprite.modulate.a = 1


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


func particles_stars():
	var star1 = scene_particles_special.instantiate()
	star1.position = position
	var star2 = scene_particles_special.instantiate()
	star2.position = position
	var star3 = scene_particles_special.instantiate()
	star3.position = position
	
	world.add_child(star1)
	world.add_child(star2)
	world.add_child(star3)

func onHit_effect():
	var hit_effect = scene_hit_effect.instantiate()
	hit_effect.position = position
	world.add_child(hit_effect)

func onBounce_effect():
	particles_stars()


func disappear_instantly():
	onHit_effect()
	particles_stars()
	modulate.a = 0
	await get_tree().create_timer(2, false).timeout
	queue_free()
