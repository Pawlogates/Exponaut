extends Sprite2D

@onready var animation_player1 = $hit_effect2/AnimationPlayer
@onready var animation_player2 = $hit_effect3/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_anim_delay_timeout():
	animation_player1.play("loop")


func _on_anim_delay_2_timeout():
	animation_player2.play("loop")
