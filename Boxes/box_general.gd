extends CharacterBody2D

@onready var world = $/root/World
@onready var player = $/root/World.player

@onready var break_bonusBox = %break_bonusBox
@onready var animation_player = %AnimationPlayer
@onready var sprite = %AnimatedSprite2D

var hit_effectScene = preload("res://Particles/hit_effect.tscn")
var dead_effect_scene = preload("res://Particles/dead_effect.tscn")
var starParticleFastScene = preload("res://Particles/particles_starFast.tscn")
var scene_particles_special2_multiple = preload("res://Particles/particles_special2_multiple.tscn")
var scene_particles_special_multiple = preload("res://Particles/particles_special_multiple.tscn")
var scene_particles_special = preload("res://Particles/particles_special.tscn")
var scene_particles_water_entered = preload("res://Particles/particles_water_entered.tscn")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var destroyed = false
var start_hp = 1
var start_item_amount = 3

var velocity_x_last = 0.0


# Properties
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
@export var item_amount = 3
@export var item_scene = preload("res://Collectibles/collectibleOrange.tscn")
@export var onDeath_rotate_sprite = true
@export var onDeath_play_anim = true
@export var onDeath_play_spriteAnim = false
@export var onDeath_spawn_deadEffect = false
@export var onHit_toggle_toggleBlocks = false
@export var onDeath_toggle_toggleBlocks = false
@export var hit_cooldown = false
@export var hit_cooldown_time = 0.8
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
		
	if not immortal:
		hp -= value
		
	if onHit_toggle_toggleBlocks:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")

func destroy():
	if not onDeath_reset:
		destroyed = true
		
		if onDeath_play_spriteAnim:
			%AnimatedSprite2D.play("destroyed")
		if onDeath_rotate_sprite:
			%sprite_root.rotation_degrees = rng.randf_range(-60.0, 30.0)
		if onDeath_play_anim:
			%AnimationPlayer.play("destroyed")
		if onDeath_spawn_deadEffect:
			var dead_effect = dead_effect_scene.instantiate()
			add_child(dead_effect)
	else:
		hp = start_hp
		if onDeath_reset_spawn_items_amount:
			item_amount = start_item_amount
	
	
	if onDeath_toggle_toggleBlocks:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleBlock", "toggleBlock_toggle")
	
	if onDeath_spawn_items:
		call_deferred("spawn_items")
	
	break_bonusBox.play()
	Globals.boxBroken.emit()
	
	var particles_special2_multiple = scene_particles_special2_multiple.instantiate()
	add_child(particles_special2_multiple)
	var particles_special_multiple = scene_particles_special_multiple.instantiate()
	add_child(particles_special_multiple)
	var particles_special = scene_particles_special.instantiate()
	add_child(particles_special)


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


func spawn_items():
	while item_amount > 0:
		item_amount -= 1
		spawn_item()
	
	var hit_effect = hit_effectScene.instantiate()
	add_child(hit_effect)


var rng = RandomNumberGenerator.new()

func spawn_item():
	var item = item_scene.instantiate()
	item.position = global_position
	item.velocity.x = rng.randf_range(300.0, -300.0)
	item.velocity.y = rng.randf_range(-100.0, -300.0)
	
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
	%AnimatedSprite2D.play("idle")
	if hit_cooldown:
		$active_cooldown.wait_time = hit_cooldown_time
	
	start_hp = hp
	start_item_amount = item_amount
	
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
	
	await get_tree().create_timer(0.2, false).timeout
	
	if destroyed:
		queue_free()


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
