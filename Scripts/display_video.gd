extends Area2D

@export var show_cooldown : float = 0.0
@export var video_file = VideoStreamTheora

var active = false


func _ready():
	modulate.a = 0.0
	$VideoStreamPlayer.stream = video_file

# The collision node has to be added manually to this ("Video Display") node.
func _on_area_entered(area: Area2D) -> void:
	if not Globals.is_valid_entity(area) : return
	if active : return
	
	active = true
	
	if show_cooldown > 0.0:
		await get_tree().create_timer(show_cooldown, false).timeout
		
		$VideoStreamPlayer.play()
		$AnimationPlayer.play("fade_in")
