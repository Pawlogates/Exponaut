extends Node2D

@onready var block: StaticBody2D
@onready var sprite: Sprite2D
@onready var collision: CollisionShape2D
@onready var animation_player: AnimationPlayer

#@onready var block: StaticBody2D = $block
#@onready var sprite: Sprite2D = $block/sprite
#@onready var collision: CollisionShape2D = $block/collision
#@onready var animation_player: AnimationPlayer = $block/AnimationPlayer

var current_anim : String

func _ready() -> void:
	add_to_group("anim_sync")
	add_to_group("level_object")
	
	var scan_always_active : Node = load("res://Other/Scenes/scan_always_active.tscn").instantiate()
	add_child(scan_always_active)
	
	for node in get_children():
		if node is Sprite2D:
			sprite = node
			break
		else:
			for node2 in node.get_children():
				if node2 is Sprite2D:
					sprite = node2
					break
	
	for node in get_children():
		if node is AnimationPlayer:
			animation_player = node
			break
		else:
			for node2 in node.get_children():
				if node2 is AnimationPlayer:
					animation_player = node2
					break
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if is_instance_valid(animation_player):
		if Globals.get_random_bool(100):
			current_anim = animation_player.current_animation
			
			await Globals.await_timer(randf_range(0.01, 0.1))
			#if not get_tree().paused and Globals.get_random_bool(10) : Globals.set_pause(true)
			get_tree().call_group("anim_sync", "sync")
		
		await Globals.await_timer(randf_range(1.0, 2.0))
		Globals.set_pause(false)
		await Globals.await_timer(randf_range(1.0, 2.0))
		Globals.set_pause(false)
	
		#Globals.set_pause(true)
#		
		#for x in 10:
			#await Globals.refreshed0_5
			##animation_player.play("RESET")
			#animation_player.stop()
			#await Globals.await_timer(0.05)
			#animation_player.play(current_anim)
			#await Globals.await_timer(0.05)
			#animation_player.advance(clamp(Globals.World.level_time, 1, 9999999))
		
		#Globals.set_pause(false)

func _physics_process(_delta: float) -> void:
	return
	if is_instance_valid(sprite) : sprite.modulate = Color.RED
	if is_instance_valid(animation_player) : pass


func sync():
	if not is_instance_valid(Globals.World) : return
	if not Globals.World.is_ready : return
	if not Globals.level_time_seconds < 45 : return
	if not is_instance_valid(animation_player) : return
	
	animation_player.stop()
	await Globals.await_timer(0.05)
	animation_player.play(current_anim)
	await Globals.await_timer(0.05)
	animation_player.advance(clamp(Globals.World.level_time, 1, 9999999))
