extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




@export var multiplier_W = 1.0
@export var multiplier_H = 1.0

var skew_W = 1
var skew_H = 1

var target_W = 1000 * multiplier_W * skew_W
var target_H = 500 * multiplier_H * skew_H


var speed = 1
var speed_target = 1

var toggle = false
var speed_toggle = false

var skew_target = 1
@export var skew_low = 0.85
@export var skew_high = 1.0

@export var scale_low_X = 1.0
@export var scale_high_X = 1.2
@export var scale_low_Y = 0.8
@export var scale_high_Y = 1.0

@export var position_target = Vector2(0, 0)


@export var speed_W = 5.0
@export var speed_H = 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %menu_deco_bg.position != position_target:
		%menu_deco_bg.position = %menu_deco_bg.position.move_toward(position_target, 1)
	
	
	%menu_deco_bg.size.x = move_toward(%menu_deco_bg.size.x, target_W, speed_W * speed)
	%menu_deco_bg.size.y = move_toward(%menu_deco_bg.size.y, target_H, speed_H * speed)
	target_W = 1000 * multiplier_W * skew_W
	target_H = 500 * multiplier_H * skew_H
	
	speed = move_toward(speed, speed_target, 0.01)
	if speed_toggle and speed == speed_target:
		speed_toggle = false
		speed_target = 0.01
	elif not speed_toggle and speed == speed_target:
		speed_toggle = true
		speed_target = 1
	
	
	
	if toggle:
		skew_W = move_toward(skew_W, skew_target, 0.03)
		skew_H = move_toward(skew_H, skew_target, 0.03)
	else:
		skew_W = move_toward(skew_W, skew_target, 0.03)
		skew_H = move_toward(skew_H, skew_target, 0.03)
	
	if toggle and skew_W == skew_target:
		skew_target = skew_low
	elif not toggle and skew_W == skew_target:
		skew_target = skew_high
	
	
	if toggle and %menu_deco_bg.size.y == target_H or toggle and %menu_deco_bg.size.x == target_W:
		toggle = false
		speed = 0
	elif not toggle and %menu_deco_bg.size.y == target_H or not toggle and %menu_deco_bg.size.x == target_W:
		toggle = true
		speed = 0
	
	
	
	
	
	if toggle:
		%menu_deco_bg.scale.x = move_toward(%menu_deco_bg.scale.x, scale_low_X, speed_W * 0.0004)
		%menu_deco_bg.scale.y = move_toward(%menu_deco_bg.scale.y, scale_low_Y, speed_H * 0.003)
	else:
		%menu_deco_bg.scale.x = move_toward(%menu_deco_bg.scale.x, scale_high_X, speed_W * 0.0004)
		%menu_deco_bg.scale.y = move_toward(%menu_deco_bg.scale.y, scale_high_Y, speed_H * 0.003)



