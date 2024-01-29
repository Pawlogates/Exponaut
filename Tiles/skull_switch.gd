extends CharacterBody2D


const SPEED = 250.0


@export var item_scene = preload("res://Collectibles/collectibleOrange.tscn")
var item = item_scene.instantiate()


var starParticleScene = preload("res://particles_star.tscn")
var starParticle = starParticleScene.instantiate()
var hit_effectScene = preload("res://hit_effect.tscn")
var hit_effect = hit_effectScene.instantiate()
var dead_effectScene = preload("res://dead_effect.tscn")
var dead_effect = dead_effectScene.instantiate()



@onready var break_bonusBox = %break_bonusBox
@onready var animation_player = %AnimationPlayer
@onready var sprite = %AnimatedSprite2D

@export var immortal = false





# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor() and not floating:
		velocity.y += gravity * delta
	
	if velocity.x != 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	
	if not floating:
		move_and_slide()





func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		
		if not destroyed and area.get_parent().velocity.y > 50:
			if Input.is_action_pressed("jump"):
				area.get_parent().velocity.y = -600
			else:
				area.get_parent().velocity.y = -300
			
			
			if not immortal:
				destroyed = true
			
			
			call_deferred("spawn_collectibles")
			
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "skull_block", "skull_block_toggle")
			
			
			
			#%Node2D.rotation_degrees = rng.randf_range(-60.0, 30.0)
			#%AnimationPlayer.play("destroyed")
			break_bonusBox.play()
			if not immortal:
				add_child(dead_effect)
				%AnimatedSprite2D.play("destroyed")
			
			Globals.boxBroken.emit()
		
		
		
	if area.is_in_group("player_projectile"):
		
		if not destroyed:
			if not immortal:
				destroyed = true
			
			
			call_deferred("spawn_collectibles")
			
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "skull_block", "skull_block_toggle")
			
			#%Node2D.rotation_degrees = rng.randf_range(-60.0, 30.0)
			#%AnimationPlayer.play("destroyed")
			break_bonusBox.play()
			if not immortal:
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
	$Area2D.set_monitorable(false)
	
	
	if not destroyed:
		%AnimatedSprite2D.play("idle")






@export var floating = false
@export var collectibleAmount = 3

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
	add_child(item)
	item.velocity.x = rng.randf_range(400.0, -400.0)
	item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	




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
