extends CharacterBody2D

#func _physics_process(delta: float) -> void:
	#if $sprite:
		#print("yes")
		#$sprite.queue_free()
		#$collision_main.queue_free()
		#$hitbox.queue_free()
		#$scan_ledge.queue_free()
		#$scan_stuck.queue_free()
