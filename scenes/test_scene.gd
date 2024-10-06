extends Node2D

@export var boid_scene : PackedScene

var boids = []
var max_boids = 120


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func add_boid(position):
	var boid_i = boid_scene.instantiate()
	boid_i.position = position
	
	boid_i.connect("deleted", boid_deleted)
	
	
	print("Added " + str(boid_i))
	add_child(boid_i)
	boids.append(boid_i)
	
	if  boids.size() > max_boids:
		var to_remove = boids[0]
		boids.remove_at(0)

		to_remove.delete()
	
	return boid_i
		
func boid_deleted(boid : Boid):
	boids.erase(boid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#for b in boids:
		#b.steer_towards = get_local_mouse_position()
	#
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#add_boid(get_local_mouse_position())
		pass
