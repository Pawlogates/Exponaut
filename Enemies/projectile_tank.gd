extends CharacterBody2D


var SPEED = 600.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var direction = get_parent().direction


func _ready():
	velocity.y = 0
	


func _physics_process(_delta):
	if direction == 1:
		%animation.flip_h = false
	else:
		%animation.flip_h = true
			
			
	if is_on_wall():
		if direction == 1:
			direction = -1
		else:
			direction = 1
		
		
	velocity.x = direction * SPEED
	move_and_slide()




func _on_remove_delay_timeout():
	queue_free()


func _on_scan_area_entered(area):
	if area.name == "Player_hitbox_main":
		Globals.playerHit1.emit()
