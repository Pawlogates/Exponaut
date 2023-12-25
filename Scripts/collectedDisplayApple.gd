extends Label

var collected = false



func _on_apple_body_entered(body):
	if body.is_in_group("player") and not collected or body.is_in_group("player_projectile") and not collected:
		collected = true
		
		self.text = str(10 * Globals.combo_tier)
