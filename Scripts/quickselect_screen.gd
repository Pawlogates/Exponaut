extends Control

@onready var container_items: FlowContainer = $container_items
@onready var bg: TextureRect = $bg


var scene_display_item = load("res://Other/Scenes/User Interface/Quick Select/quickselect_display_item.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(160.0, 2000.0)
	scale = Vector2(1, 1)
	visible = true
	
	Globals.Player.block_movement = true
	Globals.set_mouse_mode(true)
	
	create_displays_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.y != 140 : position.y = lerp(position.y, 140.0, delta * 4)


func create_displays_item():
	for item_info in Globals.qs_collected_items:
		create_display_item(item_info)
		await get_tree().create_timer(0.1, true).timeout

func create_display_item(item_info : Array):
	var display_item = scene_display_item.instantiate()
	
	display_item.item_name = item_info[0]
	display_item.item_durability = item_info[1]
	display_item.item_level = item_info[2]
	display_item.item_rarity = item_info[3]
	
	container_items.add_child(display_item)

func delete():
	Globals.Player.block_movement = false
	queue_free()
