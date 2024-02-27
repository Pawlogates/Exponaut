extends enemy_basic



const JUMP_VELOCITY = -550.0



@onready var enemy_frog = $"."

@onready var start_pos = global_position

var frog_x
var frog_y

var jumped = true




func _physics_process(delta):
	frog_x = enemy_frog.get_global_position()[0]
	frog_y = enemy_frog.get_global_position()[1]
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.


	else:
		velocity.x = move_toward(velocity.x, 0, 10)
		
	manage_animation()
	
	
	if not attacked:
		move_and_slide()
	handle_turn()



func _on_jump_timer_timeout():
	if not dead:
		velocity.y = JUMP_VELOCITY
		
	jumped = false
	





func manage_animation():
	if not dead:
		if is_on_floor() and not attacked and not attacking and not dead:
			sprite.play("standing")
			
		elif attacking:
		
			sprite.play("attack")

		elif attacked and not attacking:
			sprite.play("damage")
			
			if not particle_buffer:
				starParticle_fast = starParticle_fastScene.instantiate()
				add_child(starParticle_fast)
			
				particle_limiter.start()
				particle_buffer = true
				
		elif not is_on_floor() and not jumped:
			sprite.play("jumping")
			jumped = true







func handle_turn():
	if not dead:
		if Globals.player_posX > frog_x:
			sprite.flip_h = false
			direction = 1

		else:
			sprite.flip_h = true
			direction = -1
		




func _ready():
	basic_onReady()
	hp = 2
	
	$Timer.paused = true





#UNLOADING LOGIC

func offScreen_unload():
	basic_offScreen_unload()
	$Timer.paused = true


func offScreen_load():
	basic_offScreen_load()
	$Timer.paused = false







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
