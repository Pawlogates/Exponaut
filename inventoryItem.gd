extends Control

var item_toSpawn = null
var display_region_rect = Rect2(0, 0, 0, 0)

var inventory_itemID = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_itemID = get_tree().get_nodes_in_group("in_inventory").size()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %item_icon.region_rect != Rect2(0, 0, 0, 0):
		%item_icon.region_rect = display_region_rect
	
	#$Label.text = str("inv item ID:", inventory_itemID)



func selected_check():
	if inventory_itemID == Globals.inventory_selectedItem:
		Globals.inventory_onSpawn_scene = item_toSpawn
		add_to_group("delete_on_itemUse")
		modulate.a = 1.0
	
	else:
		remove_from_group("delete_on_itemUse")
		modulate.a = 0.5
	


#func itemOrder_correct():
	#for inventory_item in get_parent().get_children():
		#if inventory_item.is_in_group("in_inventory"):
			#get_parent().move_child(inventory_item, inventory_itemID)

