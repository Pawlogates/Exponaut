extends enemy_basic


const SPEED = 400.0
const JUMP_VELOCITY = -600.0



@onready var start_pos = global_position

var frog_x
var frog_y

var jumped = true
var flying = false





func _physics_process(delta):
	
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
			
	#frog_x = enemy_frog.get_global_position()[0]
	#frog_y = enemy_frog.get_global_position()[1]
	
	# Add the gravity.
	if not flying or dead:
		velocity.y += gravity * delta
	
	elif flying and not dead:
		velocity.y = move_toward(velocity.y, -500, 10)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	if not dead:
		velocity.x = direction * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, 10)
		
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
		
	
	
	#handle_turn()




func _on_jump_timer_timeout():
	if not dead and not flying and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	jumped = false
	




func manage_animation():
	
	if not dead and not flying:
		if is_on_floor() and not attacked and not attacking and not dead:
			sprite.play("walk")
			
		elif attacking:
		
			sprite.play("attack")

		elif attacked and not attacking:
			sprite.play("damage")
			
			if not particle_buffer:
				add_child(starParticle_fastScene.instantiate())
			
				particle_limiter.start()
				particle_buffer = true
				
		#elif not is_on_floor() and not jumped:
			#sprite.play("jumping")
			#jumped = true
	
	elif not dead:
		sprite.play("flying")
	
	







#func handle_turn():
	#if not dead:
		#if Globals.player_posX > frog_x:
			#sprite.flip_h = false

		#else:
			#sprite.flip_h = true
		


func _on_fly_cooldown_timeout():
	if not dead:
		flying = true
		%flyEnd.start()


func _on_fly_end_timeout():
	if not dead:
		flying = false
		%flyCooldown.start()
	





func _ready():
	basic_onReady()
	hp = 10





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
