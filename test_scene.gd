extends Node2D

@export var boid_scene : PackedScene

var boids = []
var max_boids = 150


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(15):
		var rand_x = randf_range(0,get_viewport_rect().size.x)
		var rand_y = randf_range(0,get_viewport_rect().size.y)
		add_boid(position)


func add_boid(position):
	var boid_i = boid_scene.instantiate()
	boid_i.position = position
	
	add_child(boid_i)
	
	if boids.size() > max_boids:
		var to_remove = boids[0]
		boids.remove_at(0)
		
		to_remove.queue_free()
	
	boids.append(boid_i)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	for b in boids:
		b.steer_towards = get_local_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#add_boid(get_local_mouse_position())
		pass
