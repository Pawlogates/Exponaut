extends StaticBody2D

@export var item_type = "none"
@export var required_item_amount = 0
var gateItem = null

signal gate_unlocked


# Called when the node enters the scene tree for the first time.
func _ready():
	gate_unlocked.connect(unlock)
	
	if item_type == "golden apple":
		gateItem = load("res://gateItem_goldenApple.tscn")
	
	
	var itemsToAdd = required_item_amount
	while itemsToAdd > 0:
		itemsToAdd -= 1
		%gateItem_container.add_child(gateItem.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		var collectedItems = 0
		var requiredItems = required_item_amount
		
		if item_type == "golden apple":
			collectedItems = Globals.collected_goldenApples
			print(Globals.collected_goldenApples)
			
		for item in %gateItem_container.get_children():
			collectedItems -= 1
			requiredItems -= 1
			
			item.modulate.a = 1
			await get_tree().create_timer(0.2, false).timeout
			
			print(str(requiredItems) + " " + str(collectedItems))
			if requiredItems <= 0:
				gate_unlocked.emit()
			
			elif collectedItems <= 0:
				$AnimationPlayer.play("locked")
				for x in %gateItem_container.get_children():
					x.modulate.a = 0.2
				
				return
	


func unlock():
	$AnimationPlayer.play("unlock")
	$CollisionShape2D.disabled = true
	$Area2D.monitoring = false
	$AudioStreamPlayer2D.play()
	
	print("unlocked")
