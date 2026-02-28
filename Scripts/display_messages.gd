extends CanvasLayer

@onready var bg: TextureRect = $container_message/bg
@onready var l_message_text: Label = $container_message/label_message_text
@onready var c_hide = $cooldown_hide
@onready var container_message: Control = $container_message
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var message_text : String = "none"
var message_textQueue : Array
var message_size = 0

func _ready():
	Globals.messages_added.connect(message_show)


func message_show(message : String = "none", anim_speed_scale : float = 1.0):
	animation_player.speed_scale = anim_speed_scale
	#message_text = Globals.display_messages_queued[0]
	#Globals.display_messages_queued.erase(Globals.display_messages_queued[0])
	message_size = Vector2(23 * message.length(), int(message.length() / 40 * 23))
	l_message_text.text = str(message)
	
	if len(message) < 56:
		bg.size.x = 24 * len(message) + 24
		bg.position.x = (container_message.size.x - bg.size.x) / 2
		
		$container_message/bg/decoration_gear.visible = false
		$container_message/bg/decoration_gear2.visible = false
		$container_message/bg/decoration_gear3.visible = false
		$container_message/bg/decoration_gear4.visible = false
	
	else:
		bg.size.x = container_message.size.x
		bg.position.x = 0
		
		$container_message/bg/decoration_gear.visible = true
		$container_message/bg/decoration_gear2.visible = true
		$container_message/bg/decoration_gear3.visible = true
		$container_message/bg/decoration_gear4.visible = true
	
	bg.size.y = container_message.size.y
	container_message.size.y = 64 * len(message) / 56
	container_message.position.y = 896.0 - len(message) / 56 * 56
	animation_player.play("show")
	c_hide.start()


func _on_timer_hide_timeout():
	animation_player.play("hide")
