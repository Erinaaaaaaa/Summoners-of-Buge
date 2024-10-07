extends Node

var entities = {
	"boid_neutral":"res://entities/Boid.tscn",
	"mana_ball":"res://entities/mana.tscn"
}

var particles = {
	"cloud":"res://entities/particles/particle_cloud.tscn",
	"die":"res://entities/particles/particle_die.tscn",
	"tooltip":"res://entities/particles/particle_info.tscn"
}

var sprites = {
	"decoy": "res://sprites/creatures/spr_butterfly.tres",
	"spidler": "res://sprites/creatures/spr_spidler.tres",
	"spee": "res://sprites/creatures/spr_spirit.tres",
	"snipe": "res://sprites/creatures/spr_snipe.tres"
}

var spell_data = {
	"decoy": {
		"cost":1,
		"count":8,
		"options": {
			"sprite": "decoy",
			"lifetime": 20,
			"max_speed": 300,
			"damage_priority": 0,
		},
		"sound":"res://sfx/no.wav"
	},
	"spee": {
		"cost":1,
		"count":3,
		"options": {
			"sprite": "spee",
			"lifetime": 10,
			"max_speed": 400,
			"damage_priority": 1
		},
		"sound":"res://sfx/bounce.wav"
	},
	"spidler": {
		"cost":2,
		"count":2,
		"options": {
			"sprite": "spidler",
			"lifetime": 17,
			"max_speed": 300,
			"damage_priority": 2
		},
		"sound":"res://sfx/bounce.wav"
	},
	"snipe": {
		"cost":1,
		"count":1,
		"options": {
			"sprite": "snipe",
			"lifetime": 7,
			"max_speed": 900,
			"damage_priority": 1
		},
		"sound":"res://sfx/bounce.wav"
	}
}

func create_instance(entity_name : String):
	if entities.has(entity_name):
		var entity_scene = load(entities[entity_name])
		return entity_scene.instantiate()
	else:
		print("ERROR: Could not find entity of name " + entity_name + " in dictionnary.")
