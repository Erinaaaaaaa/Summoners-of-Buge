extends Node

var entities = {
	"boid_neutral":"res://entities/Boid.tscn",
	
	
	"mana_ball":"res://entities/mana.tscn"
}

var particles = {
	"cloud":"res://entities/particles/particle_cloud.tscn"
}


var spell_data = {
	"spawn_weak_boids": {
		"cost":1,
		"count":5
	}
}

func create_instance(entity_name : String):
	if entities.has(entity_name):
		var entity_scene = load(entities[entity_name])
		return entity_scene.instantiate()
	else:
		print("ERROR: Could not find entity of name " + entity_name + " in dictionnary.")
