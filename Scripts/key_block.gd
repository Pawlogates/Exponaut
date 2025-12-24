extends StaticBody2D

var destroyed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not destroyed:
		%CollisionShape2D.disabled = false
		%CollisionShape2D_scan.disabled = false
		%Sprite2D.visible = true
	
	else:
		%CollisionShape2D.disabled = true
		%CollisionShape2D_scan.disabled = true
		%Sprite2D.visible = false
		$Timer.start()


# DESTROY KEY BLOCK

func key_block_destroy():
	call_deferred("deferred_key_block_destroy")


func deferred_key_block_destroy():
	if not destroyed:
		%Sprite2D.visible = false
		%CollisionShape2D.disabled = true
		%CollisionShape2D_scan.disabled = true
		
		$Timer.start()
		destroyed = true
		
		
		var dust = Globals.scene_effect_dust.instantiate()
		dust.anim_slow = true
		add_child(dust)
		
		var stars = Globals.scene_particle_star.instantiate()
		add_child(stars)

# DESTROY KEY BLOCK END


func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("key_opener"):
		key_block_destroy()
		area.get_parent().destroy_self()
