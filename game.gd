extends Node

var data = {}
var world = {}
var counters = {}

func _ready():
	init_game_data()
	
func init_game_data():
	data['name'] = 'Godot'
	
