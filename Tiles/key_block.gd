extends StaticBody2D

var destroyed = false

var effect_dustScene = preload("res://effect_dust.tscn")
var effect_dust = effect_dustScene.instantiate()

var starParticleScene = preload("res://particles_special_multiple.tscn")
var starParticle = starParticleScene.instantiate()

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



#DESTROY KEY BLOCK

func key_block_destroy():
	call_deferred("deferred_key_block_destroy")


func deferred_key_block_destroy():
	if not destroyed:
			%Sprite2D.visible = false
			%CollisionShape2D.disabled = true
			%CollisionShape2D_scan.disabled = true
			
			$Timer.start()
			destroyed = true
			
			
			var dust = effect_dustScene.instantiate()
			dust.anim_slow = true
			add_child(dust)
			
			var stars = starParticleScene.instantiate()
			add_child(stars)

#DESTROY KEY BLOCK END



func _on_area_2d_area_entered(area):
	if area.is_in_group("key_opener"):
		key_block_destroy()
		area.get_parent().destroy_self()
		
	
