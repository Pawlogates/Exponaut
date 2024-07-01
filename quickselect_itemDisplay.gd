extends Control

var item = "none"
var unlocked = false


var weaponMode = 0

var weapon_type = "none"
var attack_delay = 1
var secondaryWeapon_type = "none"
var secondaryAttack_delay = 1

var unlock_price = 100000
@onready var display_unlockPrice = %"Unlock Price Display"

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0.2
	
	if weaponMode == 0:
		if item == "weapon_basic":
			unlock_price = 10000
			%Icon.region_rect = Rect2(448, 698, 64, 64)
			weapon_type = "basic"
			attack_delay = 1.5
		elif item == "weapon_short_shotDelay":
			unlock_price = 150000
			%Icon.region_rect = Rect2(128, 640, 64, 64)
			weapon_type = "short_shotDelay"
			attack_delay = 0.1
		elif item == "weapon_ice":
			unlock_price = 50000
			%Icon.region_rect = Rect2(192, 640, 64, 64)
			weapon_type = "ice"
			attack_delay = 1.0
		elif item == "weapon_fire":
			unlock_price = 35000
			%Icon.region_rect = Rect2(64, 640, 64, 64)
			weapon_type = "fire"
			attack_delay = 1.0
		elif item == "weapon_destructive_fast_speed":
			unlock_price = 70000
			%Icon.region_rect = Rect2(0, 640, 64, 64)
			weapon_type = "destructive_fast_speed"
			attack_delay = 0.3
		elif item == "weapon_veryFast_speed":
			unlock_price = 25000
			%Icon.region_rect = Rect2(256, 640, 64, 64)
			weapon_type = "veryFast_speed"
			attack_delay = 2
		elif item == "weapon_phaser":
			unlock_price = 35000
			%Icon.region_rect = Rect2(1664, 768, 64, 64)
			weapon_type = "phaser"
			attack_delay = 999 #unused for the phaser weapon
	
	
	if weaponMode == 1:
		if item == "secondaryWeapon_basic":
			unlock_price = 25000
			%Icon.region_rect = Rect2(432, 768, 48, 48)
			secondaryWeapon_type = "basic"
			secondaryAttack_delay = 1.5
		elif item == "secondaryWeapon_fast":
			unlock_price = 100000
			%Icon.region_rect = Rect2(432, 768, 48, 48)
			secondaryWeapon_type = "fast"
			secondaryAttack_delay = 0.1
	
	
	display_unlockPrice.text = str(unlock_price)
	
	if unlocked:
		display_unlockPrice.queue_free()
		%"Unlock Label".queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_released("quickselect"):
		if %Button.focused:
			if unlocked:
				if weaponMode == 0:
					$/root/World.player.get_node("%attack_cooldown").wait_time = attack_delay
					$/root/World.player.weaponType = weapon_type
				if weaponMode == 1:
					$/root/World.player.get_node("%secondaryAttack_cooldown").wait_time = secondaryAttack_delay
					$/root/World.player.secondaryWeaponType = secondaryWeapon_type
			else:
				pass



func _on_button_pressed():
	if Input.is_action_pressed("quickselect"):
		if not unlocked:
			if Globals.level_score >= unlock_price:
				Globals.level_score -= unlock_price
				Globals.score_reduced.emit()
				display_unlockPrice.queue_free()
				%"Unlock Label".queue_free()
				unlocked = true
				
				var previous_state = $/root/World/HUD/quickselect_screen.get("unlock_state_" + item)
				if previous_state < 1:
					$/root/World/HUD/quickselect_screen.set("unlock_state_" + item, 1)
		
		#$/root/World.player.weaponType = weapon_type
		#$/root/World.player.secondaryWeaponType = secondaryWeapon_type
		#$/root/World.player.get_node("%attack_cooldown").wait_time = attack_delay
		#$/root/World.player.get_node("%secondaryAttack_cooldown").wait_time = secondaryAttack_delay
	#pass
