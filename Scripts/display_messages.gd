extends Control

@onready var bg: TextureRect = $bg
@onready var text = $text
@onready var timer_hide = $timer_hide


var message_text : String = "none"
var message_textQueue : Array
var message_size = 0

func _ready():
	Globals.sign_message_touched.connect(message_show)


func message_show():
	message_text = message_textQueue[0]
	message_textQueue.erase(message_textQueue[0])
	message_size = Vector2(23 * message_text.length(), int(message_text.length() / 40 * 23))
	text.text = str(text)
	
	$"../Timer".start()


func _on_timer_hide_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(bg, "opacity", Color.RED, 0.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(bg, "scale", Vector2(), 1.0).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(bg.queue_free)
