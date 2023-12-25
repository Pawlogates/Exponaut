extends Node2D

@export var next_level: PackedScene

@onready var canvas_layer = %CanvasLayer


@onready var level_finished = %"Level Finished"



@onready var start_in_container = %StartInContainer
@onready var start_in = %StartIn
@onready var animation_player = %AnimationPlayer

@onready var health_display = %health

var playerStartHP = 10


var levelTime = 0
var start_level_msec = 0.0
@onready var level_timeDisplay = %levelTime

@onready var start_pos = global_position






# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_tree().paused = false
	
	
	
	Globals.playerHP = playerStartHP
	health_display.text = str(Globals.playerHP)
	start_level_msec = Time.get_ticks_msec()
	
	Globals.playerHit1.connect(reduceHp1)
	Globals.playerHit2.connect(reduceHp2)
	Globals.playerHit3.connect(reduceHp3)
	
	Events.exitReached.connect(exitReached_show_screen)
	
	
	Globals.bgFile_previous = preload("res://Assets/Graphics/bg1.png")
	Globals.bgFile_current = preload("res://Assets/Graphics/bg1.png")
	
	Globals.bgChange_entered.connect(bg_change)
	
	
	if not next_level is PackedScene:
		level_finished.next_level_btn.text = "Results"
		next_level = preload("res://VictoryScreen.tscn")
	
	RenderingServer.set_default_clear_color(Color.DARK_RED)
	

	#get_tree().paused = true
	
	#start_in_container.visible = true
	start_in_container.visible = false
	
	await LevelTransition.fade_from_black()
	animation_player.play("StartInAnim")
	await animation_player.animation_finished
	#get_tree().paused = false
	
	


func _process(_delta):
	levelTime = Time.get_ticks_msec() - start_level_msec
	level_timeDisplay.text = str(levelTime / 1000.0)






#HANDLE REDUCE PLAYER HP

func reduceHp1():
	Globals.playerHP -= 1
	health_display.text = str(Globals.playerHP)
	if Globals.playerHP <= 0:
		retry()
	

func reduceHp2():
	Globals.playerHP -= 2
	health_display.text = str(Globals.playerHP)
	if Globals.playerHP <= 0:
		retry()

func reduceHp3():
	Globals.playerHP -= 3
	health_display.text = str(Globals.playerHP)
	if Globals.playerHP <= 0:
		retry()



#HANDLE LEVEL EXIT REACHED


func _on_exitReached_next_level():
	Globals.total_score = Globals.total_score + Globals.level_score
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	go_to_next_level()


func _on_exitReached_retry():
	retry()


func exitReached_show_screen():
	level_finished.show()
	level_finished.retry_btn.grab_focus()
	
	get_tree().paused = true
	


func go_to_next_level():
	
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 0
	Globals.collected_in_cycle = 0



func retry():
	
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(scene_file_path)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.playerHP = playerStartHP





#Background change


func bg_change():
	%bg_previous/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.texture = Globals.bgFile_previous
	%bg_previous/bg_transition.play("bg_hide")
	
	%bg_current/CanvasLayer/ParallaxBackground/ParallaxLayer/TextureRect.texture = Globals.bgFile_current
	%bg_current/bg_transition.play("bg_show")
	
	%bg_current.name = "bg_TEMP"
	%bg_previous.name = "bg_current"
	%bg_TEMP.name = "bg_previous"
