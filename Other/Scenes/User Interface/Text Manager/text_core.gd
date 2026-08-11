extends RichTextLabel

@export var text_main : String = "none"
@export var text_insert_start : String = "[center][wave amp=25.0 freq=5.0 connected=1]"
@export var text_insert_end : String = "[/wave]"


func _ready() -> void:
	pass


func update_text():
	if text_main != "none" : text = text_main
	if text != "none" : text_main = text
	print(text)
	text = text_main.insert(0, text_insert_start)
	print(text)
	text = text.insert(len(text), text_insert_end)
	print(text)
