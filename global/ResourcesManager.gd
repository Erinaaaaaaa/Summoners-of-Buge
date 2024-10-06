extends Node

var entities = {
	"boid_neutral":"res://entities/Boid.tscn",
	"mana_ball":"res://entities/mana.tscn"
}

var particles = {
	"cloud":"res://entities/particles/particle_cloud.tscn"
}

var sprites = {
	"decoy": "res://placeholder/spr_decoy.tres",
	"spidler": "res://placeholder/spidler.png",
	"spee": "res://placeholder/spr_spee.tres"
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
		}
	},
	"spee": {
		"cost":1,
		"count":3,
		"options": {
			"sprite": "spee",
			"lifetime": 10,
			"max_speed": 400,
			"damage_priority": 1
		}
	}
}

func create_instance(entity_name : String):
	if entities.has(entity_name):
		var entity_scene = load(entities[entity_name])
		return entity_scene.instantiate()
	else:
		print("ERROR: Could not find entity of name " + entity_name + " in dictionnary.")
