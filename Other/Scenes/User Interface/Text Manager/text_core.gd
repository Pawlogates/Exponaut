extends RichTextLabel

@export var text_main : String = "none"
@export var text_insert_start : String = "[center][wave amp=25.0 freq=5.0 connected=1]"
@export var text_insert_end : String = "[/wave]"


func _ready() -> void:
	if text_main == "none" : text_main = text


func update_text():
	if text_main != text : text_main = text
	text = text.insert(0, text_insert_start)
	text = text.insert(len(text), text_insert_end)
	print(text_insert_end)
	print(text)
