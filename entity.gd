extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("main interactions") # section start

@export var collectable = true
@export var hittable = false
@export var collidable = false

@export_group("") # section end

@export_group("general properties") # section start

@export var score_value = 25
@export var health_value = 3
@export var damage_value = 1

@export var can_move = false
@export var can_move_x = false
@export var can_move_y = false
@export var gravity_value = 1.0

@export_enum("normal", "move_x", "move_y", "move_xy", "follow_player_x", "follow_player_y", "follow_player_xy", "follow_player_x_if_spotted", "follow_player_y_if_spotted", "follow_player_xy_if_spotted", "chase_player_x", "chase_player_y", "chase_player_xy", "chase_player_x_if_spotted", "chase_player_y_if_spotted", "chase_player_xy_if_spotted", "wave_H", "wave_V", "move_around_startPosition_x", "move_around_startPosition_y", "move_around_startPosition_xy", "move_around_startPosition_x_if_not_spotted", "move_around_startPosition_y_if_not_spotted", "move_around_startPosition_xy_if_not_spotted") var movement_type: String

@export_group("") # section end

func _process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_hitbox_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
