extends Control

@onready var icon: Sprite2D = $icon
@onready var container_sell: VBoxContainer = $container_main/container_sell
@onready var label_sell_reward: Label = $container_main/container_sell/label_sell_reward
@onready var btn_sell: Button = $container_main/container_sell/btn_sell
@onready var container_dismantle: VBoxContainer = $container_main/container_dismantle
@onready var btn_dismantle: Button = $container_main/container_dismantle/btn_dismantle
@onready var label_dismantle_reward: Label = $container_main/container_dismantle/label_dismantle_reward
@onready var label_name: Label = $container_main/label_name
@onready var menu_bg: Control = $menu_bg
@onready var container_main: Control = $container_main


@export var item_name : String = "wpn_phaser"
@export var item_durability : float = 100.0
@export var item_level : int = 1
@export var item_rarity : int = 1

@export var icon_rect : Rect2 = Rect2(384.0, 640.0, 64, 64)


var sell_reward : int = 9999
var dismantle_reward : int = 3
var upgrade_level_price : int = 10000
var upgrade_rarity_price : int = 500000


# Called when the node enters the scene tree for the first time.
func _ready():
	label_name.text = str(item_name)
	sell_reward = item_durability * item_level * (item_rarity * item_rarity)
	label_sell_reward.text = str(sell_reward)
	dismantle_reward = sell_reward / 10000
	label_dismantle_reward.text = ""
	for x in dismantle_reward:
		label_dismantle_reward.text += "I"
	
	if item_rarity == 1 : icon.modulate = Color.WHITE
	if item_rarity == 2 : icon.modulate = Color.GREEN_YELLOW
	if item_rarity == 3 : icon.modulate = Color.SKY_BLUE
	if item_rarity == 4 : icon.modulate = Color.MEDIUM_PURPLE
	if item_rarity == 5 : icon.modulate = Color.GOLD
	
	if item_rarity == 1 : menu_bg.modulate = Color.WHITE
	if item_rarity == 2 : menu_bg.modulate = Color.GREEN_YELLOW
	if item_rarity == 3 : menu_bg.modulate = Color.SKY_BLUE
	if item_rarity == 4 : menu_bg.modulate = Color.MEDIUM_PURPLE
	if item_rarity == 5 : menu_bg.modulate = Color.GOLD

func _process(delta):
	if focused:
		container_main.modulate.a = move_toward(container_main.modulate.a, 1.0, delta * 4)
	else:
		container_main.modulate.a = move_toward(container_main.modulate.a, 0.0, delta * 4)


var focused : bool = false

func _on_mouse_entered() -> void:
	focused = true

func _on_mouse_exited() -> void:
	focused = false
