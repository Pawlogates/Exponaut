extends Node2D

@export var next_level: PackedScene

@onready var canvas_layer = %CanvasLayer


@onready var level_finished = %"Level Finished"



@onready var start_in_container = %StartInContainer
@onready var start_in = %StartIn
@onready var animation_player = %AnimationPlayer

@onready var health_display = %health
var playerStartHP = 9


var levelTime = 0
var start_level_msec = 0.0
@onready var level_timeDisplay = %levelTime

@onready var start_pos = global_position






# Called when the node enters the scene tree for the first time.
func _ready():
	health_display.text = str(Globals.playerHP)
	start_level_msec = Time.get_ticks_msec()
	
	Globals.playerHit1.connect(reduceHp1)
	Globals.playerHit2.connect(reduceHp2)
	Globals.playerHit3.connect(reduceHp3)
	
	Globals.ExitZoneEntered.connect(ExitZoneNextLevel)
	
	if not next_level is PackedScene:
		level_finished.next_level_btn.text = "Results"
		next_level = load("res://VictoryScreen.tscn")
	
	RenderingServer.set_default_clear_color(Color.DARK_RED)
	
	Events.all_collected.connect(show_collected_screen)
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




func show_collected_screen():
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
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_file_path)
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	Globals.playerHP = playerStartHP


func ExitZoneNextLevel():
	Events.all_collected.emit()


func _on_all_collected_next_level():
	Globals.total_score = Globals.total_score + Globals.level_score
	go_to_next_level()
	
	Globals.level_score = 0
	Globals.combo_score = 0
	Globals.combo_tier = 1
	Globals.collected_in_cycle = 0
	
	
func _on_all_collected_retry():
	retry()
	



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
