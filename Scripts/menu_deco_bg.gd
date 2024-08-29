extends Control

@onready var menu_deco_bg = %menu_deco_bg

@export var multiplier_W = 1.0
@export var multiplier_H = 1.0

var skew_W = 1
var skew_H = 1

var target_W = 1000 * multiplier_W * skew_W
var target_H = 500 * multiplier_H * skew_H

var speed = 1

var toggle = false

var skew_target = 1

@export var skew_low = 0.85
@export var skew_high = 1.0

@export var scale_low_X = 1.2
@export var scale_high_X = 1.4
@export var scale_low_Y = 1.1
@export var scale_high_Y = 1.2

@export var position_target = Vector2(-350, -200)

@export var speed_W = 5.0
@export var speed_H = 2.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if menu_deco_bg.position != position_target:
		menu_deco_bg.position = menu_deco_bg.position.move_toward(position_target, 100 * delta)
	
	menu_deco_bg.size.x = move_toward(menu_deco_bg.size.x, target_W, speed_W * speed * delta * 50)
	menu_deco_bg.size.y = move_toward(menu_deco_bg.size.y, target_H, speed_H * speed * delta * 50)
	
	target_W = 1000 * multiplier_W * skew_W
	target_H = 500 * multiplier_H * skew_H
	
	speed_W = menu_deco_bg.size.x / target_W
	speed_H = menu_deco_bg.size.y / target_H
	
	
	if toggle:
		skew_W = move_toward(skew_W, skew_target, 1.5 * delta)
		skew_H = move_toward(skew_H, skew_target, 1.5 * delta)
	else:
		skew_W = move_toward(skew_W, skew_target, 1.5 * delta)
		skew_H = move_toward(skew_H, skew_target, 1.5 * delta)
	
	if toggle and skew_W == skew_target:
		skew_target = skew_low
	elif not toggle and skew_W == skew_target:
		skew_target = skew_high
	
	
	if toggle and menu_deco_bg.size.y == target_H or toggle and menu_deco_bg.size.x == target_W:
		toggle = false
	elif not toggle and menu_deco_bg.size.y == target_H or not toggle and menu_deco_bg.size.x == target_W:
		toggle = true
	
	
	if toggle:
		menu_deco_bg.scale.x = move_toward(menu_deco_bg.scale.x, scale_low_X, speed_W * 0.06 * delta / 2)
		menu_deco_bg.scale.y = move_toward(menu_deco_bg.scale.y, scale_low_Y, speed_H * 0.3 * delta / 2)
	else:
		menu_deco_bg.scale.x = move_toward(menu_deco_bg.scale.x, scale_high_X, speed_W * 0.06 * delta / 2)
		menu_deco_bg.scale.y = move_toward(menu_deco_bg.scale.y, scale_high_Y, speed_H * 0.3 * delta / 2)
