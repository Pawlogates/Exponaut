extends Node2D

var starParticleScene = load("res://particles_star.tscn")
var starParticle = starParticleScene.instantiate()

var collected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_collectible_entered(body):
	if body.is_in_group("player") and not collected or body.is_in_group("player_projectile") and not collected:
		collected = true
		
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
		starParticle = starParticleScene.instantiate()
		add_child(starParticle)
	

