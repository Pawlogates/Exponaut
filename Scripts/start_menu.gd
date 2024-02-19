extends CenterContainer

var Overworld = preload("res://Levels/Overworld.tscn")
var mapScreen = preload("res://map_screen.tscn")


@export var debug_mode = false



func _ready():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%resolution_menu.visible = false
	%resolution_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%refreshrate_menu.visible = false
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%audio_menu.visible = false
	%audio_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%gameplay_menu.visible = false
	%gameplay_menu.process_mode = Node.PROCESS_MODE_DISABLED
	%other_menu.visible = false
	%other_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	
	%ColorRect.visible = true
	
	%menu_deco_bg.visible = false
	%menu_deco_bg.process_mode = Node.PROCESS_MODE_DISABLED
	
	
	
	if debug_mode:
		%main_menu.visible = true
		%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		%StartGame.grab_focus()
	
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	await get_tree().create_timer(0.5, false).timeout
	%fade_animation.play("fade_from_black")
	await get_tree().create_timer(3, false).timeout
	%fade_animation.play("fade_to_black")
	





func start_game():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%episodeSelect_menu.visible = true
	%episodeSelect_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%"Rooster Island".grab_focus()






#SELECTED EPISODE

func _on_episode_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(mapScreen)
	LevelTransition.fade_from_black()
	





var change_bg_to_main = true

func _on_fade_animation_animation_finished(anim_name):
	if change_bg_to_main and anim_name == "fade_to_black":
		%background.texture = preload("res://Assets/Graphics/menu_main.png")
		%fade_animation.play("fade_from_black")
		
		%main_menu.visible = true
		%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		
		%menu_deco_bg.visible = true
		%menu_deco_bg.process_mode = Node.PROCESS_MODE_ALWAYS
		
		%StartGame.grab_focus()
		
		$AudioStreamPlayer2D.play()




#BUTTONS

func _on_start_game_pressed():
	start_game()
	


func _on_quit_pressed():
	get_tree().quit()
	


func _on_options_pressed():
	%main_menu.visible = false
	%main_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Graphics.grab_focus()


func _on_graphics_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%Resolution.grab_focus()


func _on_resolution_pressed():
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%resolution_menu.visible = true
	%resolution_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.8
	%menu_deco_bg_root.position_target = Vector2(-424, -348)
	
	%AutoResolution.grab_focus()


func _on_refreshrate_pressed():
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%refreshrate_menu.visible = true
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 0.8
	%menu_deco_bg_root.position_target = Vector2(-452, -196)
	
	%AutoRefreshrate.grab_focus()

func _on_audio_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%audio_menu.visible = true
	%audio_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%"Music +".grab_focus()


func _on_gameplay_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%gameplay_menu.visible = true
	%gameplay_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%"User Interface Type".grab_focus()


func _on_other_pressed():
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%other_menu.visible = true
	%other_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%"Option 1".grab_focus()









#RETURN BUTTONS

func _on_returnOptions_pressed():
	%main_menu.visible = true
	%main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%options_menu.visible = false
	%options_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 1
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-416, -316)
	
	%StartGame.grab_focus()


func _on_returnGraphics_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%graphics_menu.visible = false
	%graphics_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Graphics.grab_focus()


func _on_return_resolution_pressed():
	%resolution_menu.visible = false
	%resolution_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%Resolution.grab_focus()


func _on_return_refreshrate_pressed():
	%refreshrate_menu.visible = false
	%refreshrate_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%graphics_menu.visible = true
	%graphics_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%menu_deco_bg_root.multiplier_W = 1.2
	%menu_deco_bg_root.multiplier_H = 1
	%menu_deco_bg_root.position_target = Vector2(-484, -348)
	
	%Refreshrate.grab_focus()


func _on_return_audio_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%audio_menu.visible = false
	%audio_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Audio.grab_focus()


func _on_return_other_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%other_menu.visible = false
	%other_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Other.grab_focus()


func _on_return_gameplay_pressed():
	%options_menu.visible = true
	%options_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	%gameplay_menu.visible = false
	%gameplay_menu.process_mode = Node.PROCESS_MODE_DISABLED
	
	%menu_deco_bg_root.multiplier_W = 0.6
	%menu_deco_bg_root.multiplier_H = 1.6
	%menu_deco_bg_root.position_target = Vector2(-416, -348)
	
	%Gameplay.grab_focus()








func _on_bonus_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(Overworld)
	LevelTransition.fade_from_black()





func _on_disable_quicksaves_pressed():
	if Globals.quicksaves_enabled == true:
		Globals.quicksaves_enabled = false
		$"gameplay_menu/menu_container/Disable Quicksaves/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Enable Quicksaves[/wave]"
	
	elif Globals.quicksaves_enabled == false:
		Globals.quicksaves_enabled = true
		$"gameplay_menu/menu_container/Disable Quicksaves/RichTextLabel".text = "[wave amp=50.0 freq=10.0 connected=1]Disable Quicksaves[/wave]"




func display_stretch_viewport_on():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT


func display_stretch_viewport_off():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
