extends Control

@onready var text_container: Label = $display/text_container
@onready var bg: ColorRect = $display/bg

var text : Array
var textQueue : Array


func _ready():
	textQueue.append_array(Globals.display_debug_textQueue)
	insert_queued_messages()


func insert_queued_messages():
	var bg_size = Vector2(0, 0)
	for message in textQueue:
		text.append(str(message) + "<br>")
		bg.size += Vector2(message.length * 23, 23)
		text.append(message)
	
	text_container.text = str(text)
	textQueue.clear()


func _on_close_pressed() -> void:
	pass # Replace with function body.
