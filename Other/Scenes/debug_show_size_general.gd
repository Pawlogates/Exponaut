extends ColorRect

var master_node : Node

func _ready() -> void:
	if not is_instance_valid(Globals.World) or (not Globals.World.debug_show_unloader_range and not Globals.debug_mode) : queue_free()
	
	master_node = get_parent()
	master_node.z_index = 200
	master_node.get_parent().z_index = 250
	
	var margin : float = 1.0 + 2.0 / master_node.scale.x
	
	if master_node is VisibleOnScreenNotifier2D:
		position = master_node.rect.position * margin
		size = master_node.rect.size * margin
	
	modulate.a /= 4
	visible = true

func _physics_process(delta: float) -> void:
	if not Globals.debug_mode : queue_free()
