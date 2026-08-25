extends Node2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export var anim_speed : float = -1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#await get_tree().create_timer(1, true).timeout
	
	if anim_speed == -1.0 : anim_speed = randf_range(0.5, 4.0)
	rotation_degrees = randi_range(0, 360)
	
	animation_player.speed_scale = anim_speed
	animation_player.play("afterSpawn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_animation_player_animation_finished(_anim_name):
	queue_free()
