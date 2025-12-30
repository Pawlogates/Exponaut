extends Control

@onready var fill: ColorRect = $slot_fill/fill

@onready var animation_player: AnimationPlayer = $slot_fill/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $slot_fill/AnimationPlayer2

@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect2: TextureRect = $TextureRect2

var id = 0
var active = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func activate():
	if active : return
	active = true
	fill_reset()
	
	animation_player.stop()
	animation_player.play("show")
	Globals.spawn_scenes(self, Globals.scene_particle_splash, 1, Vector2(0, 0))

func deactivate():
	if not active : return
	active = false
	fill_reset()
	
	var tween1 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	var tween2 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_BACK)
	var tween3 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SPRING)
	var tween4 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	
	tween1.tween_property(fill, "position:x", randi_range(-2000, 2000), randf_range(2, 4))
	tween2.tween_property(fill, "position:y", randi_range(1000, 2000), randf_range(1.5, 3))
	tween3.tween_property(fill, "rotation_degrees", randi_range(-720, 720), randf_range(1, 2))
	var random_scale = randi_range(0.25, 2)
	tween4.tween_property(fill, "scale", Vector2(random_scale, random_scale), randf_range(1, 2))
	tween1.tween_property(fill, "visible", false, 0)

func fill_reset():
	fill.position = Vector2(-8, 12)
	fill.rotation_degrees = 0
	fill.scale = Vector2(1, 1)
	fill.visible = true
