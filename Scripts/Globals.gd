extends Node


#variables

var direction = 1

var level_score = 0
var combo_score = 0
var combo_tier = 1
var collected_in_cycle = 0

var total_score = 0


var playerHP = 9
var player_posX
var player_posY



#signals

signal apple_collected
signal carrot_collected
signal cheese_collected
signal jewelGreen_collected

signal ExitZoneEntered

signal playerHit1
signal playerHit2
signal playerHit3

signal shot_charged
