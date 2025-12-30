extends Control

var scene_charges_slot = preload("res://Other/Scenes/User Interface/HUD/projectile_charge_slot.tscn")

var projectile_charges_max = 4
var projectile_charges = 4

@onready var projectile_charges_left: Control = $projectile_charges_left
@onready var projectile_charges_middle: Control = $projectile_charges_middle
@onready var projectile_charges_right: Control = $projectile_charges_right

@onready var slots_max: Label = $slots_max
@onready var slots_active: Label = $slots_active

@onready var timer_block_buttons: Timer = $timer_block_buttons

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var slot_left_animation_player: AnimationPlayer = $projectile_charges_left/slot_fill/AnimationPlayer


var block_buttons = false

@onready var slot_left_fill: Control = $projectile_charges_left/slot_fill

func _ready() -> void:
	await get_tree().create_timer(0.5, false).timeout
	
	check_projectile_charges()

func _physics_process(delta: float) -> void:
	pass


func check_projectile_charges():
	var current_slots = projectile_charges_middle.get_children()
	
	for new_slot_id in range(projectile_charges_max - 1): # The first slot is not a part of the system that dynamically adds more slots.
		var skip_slot = false
		
		for slot in current_slots:
			if slot.id == new_slot_id:
				skip_slot = true
		
		if skip_slot:
			continue
		
		var new_slot = scene_charges_slot.instantiate()
		new_slot.id = new_slot_id
		new_slot.position.x += 16 * new_slot_id
		projectile_charges_middle.add_child(new_slot)
		new_slot.animation_player_2.stop()
		new_slot.animation_player_2.play("glow")
	
	if projectile_charges >= 1:
		slot_left_activate()
	else:
		slot_left_deactivate()
	
	current_slots = projectile_charges_middle.get_children()
	
	for slot in current_slots:
		if slot.id > projectile_charges - 2:
			slot.deactivate()
		
		else:
			slot.activate()
		
		if slot.id > projectile_charges_max - 2:
			slot.queue_free()
		
		else:
			animation_player.stop()
			animation_player.play("glow")
			#Globals.anim_glow(self, Globals.material_rainbow, 1) need to properly implement this quick tween editor method first.
		
		if slot.id >= projectile_charges_max - 2 and projectile_charges - 2 >= projectile_charges_max - 2:
			slot.texture_rect.visible = false # normal (open)
			slot.texture_rect2.visible = true # closed
			slot.fill.scale.x = 1.5
		
		else:
			slot.texture_rect.visible = true
			slot.texture_rect2.visible = false
			slot.fill.scale.x = 1
	
	slots_active.text = str(projectile_charges)
	slots_max.text = str(projectile_charges_max)


func _on_debug_charges_add_pressed() -> void:
	if block_buttons : return
	block_buttons = true
	
	timer_block_buttons.wait_time = 0.15
	timer_block_buttons.start()
	
	add_charges(1)

func _on_debug_charges_subtract_pressed() -> void:
	if block_buttons : return
	block_buttons = true
	
	timer_block_buttons.wait_time = 4
	timer_block_buttons.start()
	
	add_charges(-1)

func _on_debug_charges_max_add_pressed() -> void:
	if block_buttons : return
	block_buttons = true
	
	timer_block_buttons.wait_time = 0.15
	timer_block_buttons.start()
	
	add_slots(1)

func _on_debug_charges_max_subtract_pressed() -> void:
	if block_buttons : return
	block_buttons = true
	
	timer_block_buttons.wait_time = 0.15
	timer_block_buttons.start()
	
	add_slots(-1)

func _on_timer_block_buttons_timeout() -> void:
	block_buttons = false

func add_charges(quantity):
	projectile_charges += quantity
	check_projectile_charges()
	
func add_slots(quantity):
	projectile_charges_max += quantity
	check_projectile_charges()

func _on_debug_charges_add_10_pressed() -> void:
	if block_buttons : return
	block_buttons = true
	
	timer_block_buttons.wait_time = 0.15
	timer_block_buttons.start()
	
	for x in range(10):
		add_charges(1)
		await get_tree().create_timer(0.05, false).timeout

func _on_debug_charges_subtract_10_pressed() -> void:
	if block_buttons : return
	block_buttons = true
	
	timer_block_buttons.wait_time = 4
	timer_block_buttons.start()
	
	for x in range(10):
		add_charges(-1)
		await get_tree().create_timer(0.05, false).timeout


var slot_left_active = false

func slot_left_activate():
	if slot_left_active : return
	slot_left_active = true
	slot_left_fill_reset()
	
	slot_left_animation_player.play("slot_left_show")
	Globals.spawn_scenes(self, Globals.scene_particle_splash, 1, Vector2(-400, -400))

func slot_left_deactivate():
	if not slot_left_active : return
	slot_left_active = false
	slot_left_fill_reset()
	var tween1 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	var tween2 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_BACK)
	var tween3 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SPRING)
	var tween4 = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	
	tween1.tween_property(slot_left_fill, "position:x", randi_range(-2000, 2000), randf_range(2, 4))
	tween2.tween_property(slot_left_fill, "position:y", randi_range(1000, 2000), randf_range(1.5, 3))
	tween3.tween_property(slot_left_fill, "rotation_degrees", randi_range(-720, 720), randf_range(1, 2))
	var random_scale = randi_range(0.25, 2)
	tween4.tween_property(slot_left_fill, "scale", Vector2(random_scale, random_scale), randf_range(1, 2))
	tween1.tween_property(slot_left_fill, "visible", false, 0)

func slot_left_fill_reset():
	slot_left_fill.position = Vector2(0, 0)
	slot_left_fill.rotation_degrees = 0
	slot_left_fill.scale = Vector2(1, 1)
	slot_left_fill.visible = true
