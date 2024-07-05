extends CharacterBody2D

@onready var break_bonusBox = %break_bonusBox
@onready var animation_player = %AnimationPlayer
@onready var sprite = %AnimatedSprite2D

var starParticleScene = preload("res://particles_special_multiple.tscn")
var hit_effectScene = preload("res://hit_effect.tscn")
var dead_effect_scene = preload("res://dead_effect.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var destroyed = false
var start_hp = 1
var start_item_amount = 3


#Properties
@export var immortal = false
@export var onDeath_reset = false
@export var onDeath_reset_spawn_items_amount = true
@export var hp = 1
@export var SPEED = 250.0
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
@export var onHit_toggle_skullBlocks = false
@export var onDeath_toggle_skullBlocks = false
@export var hit_cooldown = false
@export var hit_cooldown_time = 0.8
#!Properties

func _physics_process(delta):
	if not is_on_floor() and not floating:
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	
	if velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	if not destroyed and not floating:
		move_and_slide()
		

#AREA ENTERED
func _on_area_2d_area_entered(area):
	if not active:
		print("BonusBox entered, but it was inactive.")
		return
	
	if area.is_in_group("player") and not area.get_parent().is_in_group("weightless"):
		if not destroyed:
			if player_bounce(area):
				var damageValue = area.get_parent().damageValue
				reduce_hp(damageValue)
			
			if hp <= 0:
				destroy()
		
		
	if area.is_in_group("player_projectile"):
		if not destroyed:
			var damageValue = area.get_parent().damageValue
			reduce_hp(damageValue)
			
			if hp <= 0:
				destroy()

#AREA ENTERED



func reduce_hp(damageValue):
	if hit_cooldown:
		active = false
		$active_cooldown.start()
		
	if not immortal:
		hp -= damageValue
		
	if onHit_toggle_skullBlocks:
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
	
	
	if onDeath_toggle_skullBlocks:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "toggleSwitch", "toggleBlock_toggle")
	
	if onDeath_spawn_items:
		call_deferred("spawn_items")
	
	break_bonusBox.play()
	Globals.boxBroken.emit()
	
	var starParticle = starParticleScene.instantiate()
	add_child(starParticle)

func player_bounce(area):
	if area.get_parent().velocity.y > bounce_min_velocity:
		if Input.is_action_pressed("jump"):
			area.get_parent().velocity.y = bounceJump_give_velocity
		else:
			area.get_parent().velocity.y = bounce_give_velocity
		
		area.get_parent().air_jump = true
		area.get_parent().wall_jump = true
		
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
	item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	get_parent().get_parent().add_child(item)



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
