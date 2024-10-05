extends Node2D

@export var boid_scene : PackedScene

var boids = []
var max_boids = 100000


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(100):
		pass #add_boid(Vector2(50,50))


func add_boid(position):
	var boid_i = boid_scene.instantiate()
	boid_i.position = position
	
	add_child(boid_i)
	boids.append(boid_i)
	
	print(boids.size())
	
	if  boids.size() > max_boids:
		var to_remove = boids[0]
		boids.remove_at(0)
		
		print("removing " + str(to_remove))
		to_remove.queue_free()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for b in boids:
		b.steer_towards = get_local_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		add_boid(get_local_mouse_position())
		pass
