extends Node

func create_particle(particle_name : String, parent_node : Node2D):
	var particle_scene = load(ResourcesManager.particles[particle_name])
	var particle_instance = particle_scene.instantiate()
	
	parent_node.add_child(particle_instance)
	
	return particle_instance
