extends enemy_basic


const SPEED = 100.0
const JUMP_VELOCITY = -250.0




func _physics_process(delta):
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
			
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta)
	
	
	if not dead:
		velocity.y = 0
	else:
		velocity.y = move_toward(velocity.y, 800, 400 * delta)
	
	
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
	







func manage_animation():
	if not dead:
		if not attacked and not attacking:
			sprite.play("flying")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
				
		if attacking:
			sprite.play("attack")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
				
		if attacked and not attacking:
			sprite.play("damage")
			if direction == 1:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
			
			if not particle_buffer:
				starParticle_fast = starParticle_fastScene.instantiate()
				add_child(starParticle_fast)
			
				particle_limiter.start()
				particle_buffer = true
			






func _ready():
	hp = 2
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
