extends CharacterBody2D

var direction = 1
var direction_v = 1

var SPEED = 250

var homing = false
var collected = false

@onready var player = $/root/World.player
@onready var world = $/root/World
@onready var particle_visual = $particle

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(randi_range(-300, 300), randi_range(-300, 50))
	
	var scale_base : float = randf_range(-2, 0.5)
	particle_visual.scale = Vector2(scale_base, scale_base)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not homing:
		velocity.x = move_toward(velocity.x, 0, delta * 10)
		velocity.y += 5
		particle_visual.rotation_degrees = move_toward(particle_visual.rotation_degrees, direction_v * SPEED * -1, delta * 20)
		
		move_and_slide()
		return
	
	if collected:
		scale = scale.move_toward(Vector2(0.1, 0.1), delta)
		if scale == Vector2(0.1, 0.1):
			queue_free()
		return
	
	if position.x > player.position.x:
		direction = -1
	else:
		direction = 1
		
	if position.y > player.position.y:
		direction_v = -1
	else:
		direction_v = 1
	
	velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * 3)
	velocity.y = move_toward(velocity.y, direction_v * SPEED, SPEED * delta * 6)
	
	particle_visual.rotation_degrees = move_toward(particle_visual.rotation_degrees, direction_v * SPEED, SPEED * delta / 2)
	
	move_and_slide()


func _on_timer_timeout():
	homing = true
	await get_tree().create_timer(randf_range(0.2, 0.6), false).timeout
	$speed_change_timer.start()


func _on_delete_timer_timeout():
	queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player_root"):
		if homing:
			collected = true


func _on_speed_change_timer_timeout():
	SPEED = randi_range(250, 1000)
