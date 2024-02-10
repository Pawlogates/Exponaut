extends enemy_basic


const SPEED = 100.0
const JUMP_VELOCITY = -250.0

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


func _physics_process(delta):
	#if is_on_wall():
		#if direction == 1:
			#direction = -1
		#else:
			#direction = 1
			#
	#
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, 500 * delta)
	
	
	
	velocity.y = move_toward(velocity.y, 1200, 600 * delta)
	
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
	







func manage_animation():
	if not dead:
		sprite.play("idle")






func _ready():
	hp = 1
	$Timer.start()
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


func _on_timer_timeout():
	effect_dust = effect_dustScene.instantiate()
	effect_dust.global_position = global_position
	get_parent().add_child(effect_dust)
	
	orbParticle = orbParticleScene.instantiate()
	orbParticle.global_position = global_position
	get_parent().add_child(orbParticle)
	
	queue_free()
