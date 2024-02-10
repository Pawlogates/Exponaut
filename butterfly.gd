extends enemy_basic


const SPEED = 50.0
const JUMP_VELOCITY = -250.0

var velocity_V_target = -100
var toggle = true


var starParticleScene = preload("res://particles_special.tscn")
var starParticle2Scene = preload("res://particles_star.tscn")
var orbParticleScene = preload("res://particles_special2_multiple.tscn")
var starParticle = starParticleScene.instantiate()
var starParticle2 = starParticle2Scene.instantiate()
var orbParticle = orbParticleScene.instantiate()

var splashParticleScene = preload("res://particles_water_entered.tscn")
var splashParticle = splashParticleScene.instantiate()

var effect_dustScene = preload("res://effect_dust.tscn")
var effect_dust = effect_dustScene.instantiate()

var effect_dust_moveUpScene = preload("res://effect_dust_moveUp.tscn")
var effect_dust_moveUp = effect_dustScene.instantiate()


func _physics_process(delta):
	if dead:
		return
	
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
		
		basic_sprite_flipDirection()
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta)
	
	
	if dead:
		velocity.y = move_toward(velocity.y, 800, 400 * delta)
	
	if not dead:
		if velocity.y == velocity_V_target:
			if toggle:
				toggle = false
				velocity_V_target = 100
			else:
				toggle = true
				velocity_V_target = -100
			
		
	velocity.y = move_toward(velocity.y, velocity_V_target, 100 * delta)
			
	manage_animation()
	
	if not dead:
		move_and_slide()
	




func manage_animation():
	sprite.play("flying")




@export var butterfly_hp = 1

func _ready():
	hp = butterfly_hp
	direction = 1
	basic_onReady()
	




#UNLOADING LOGIC

func offScreen_unload():
	basic_offScreen_unload()


func offScreen_load():
	basic_offScreen_load()





#SAVE START

func save():
	var save_dict = {
		"loadingZone" : loadingZone,
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"direction" : direction,
		"health" : hp,
		
	}
	return save_dict

#SAVE END





func _on_player_entered(area):
	if area.is_in_group("player") and area.get_parent().velocity.y > 50:
		if Input.is_action_pressed("jump"):
			area.get_parent().velocity.y = -600
			spawn_particles()
			
		else:
			area.get_parent().velocity.y = -300
			spawn_particles()
		
		
		hp -= 1
		if hp <= 0:
			dead = true
			
			if spawn_item_onDeath:
				call_deferred("spawn_collectibles")
				
			if give_score_onDeath:
				if Globals.collected_in_cycle == 0:
					Globals.level_score += scoreValue
				
				else:
					Globals.level_score += scoreValue
					Globals.combo_score += scoreValue * Globals.combo_tier
				
				Globals.itemCollected.emit()
				
				%collectedDisplay.text = str(scoreValue * Globals.combo_tier)
				%AnimationPlayer.play("score_value")
			
			
			add_child(starParticleScene.instantiate())
			add_child(starParticleScene.instantiate())
			add_child(starParticleScene.instantiate())
			add_child(effect_dust_moveUpScene.instantiate())
			
			$Area2D.set_deferred("monitoring", false)
			$Area2D.set_deferred("monitorable", false)
			$AnimatedSprite2D.visible = false
			$Timer.stop()
			
			



@export var particles_star = true
@export var particles_golden = true
@export var particles_splash = true

func spawn_particles():
	if particles_star:
		add_child(starParticleScene.instantiate())
	if particles_golden:
		add_child(orbParticleScene.instantiate())
	if particles_splash:
		add_child(splashParticleScene.instantiate())





@export var give_score_onDeath = false
@export var scoreValue = 1000
@export var spawn_item_onDeath = true
@export var item_scene = preload("res://Collectibles/collectibleApple.tscn")
@export var collectibleAmount = 3
@export var throw_item_around = false
@export var spread_position = true

var item = item_scene.instantiate()


func spawn_collectibles():
	while collectibleAmount > 0:
		collectibleAmount -= 1
		spawn_item()
		
	
	hit_effect = hit_effectScene.instantiate()
	add_child(hit_effect)



var rng = RandomNumberGenerator.new()

func spawn_item():
	item = item_scene.instantiate()
	
	if throw_item_around:
		item.velocity.x = rng.randf_range(400.0, -400.0)
		item.velocity.y = min(-abs(item.velocity.x) * 1.2, 100)
	
	if spread_position:
		item.position = Vector2(rng.randf_range(40.0, -40.0), rng.randf_range(40.0, -40.0))
	
	
	
	add_child(item)






func _on_timer_timeout():
	if direction == 1:
		direction = -1
	else:
		direction = 1
		
	basic_sprite_flipDirection()
