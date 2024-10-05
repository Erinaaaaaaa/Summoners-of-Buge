extends Node2D

@export var boid_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(100):
		add_boid()


func add_boid():
	var boid_i = boid_scene.instantiate()
	boid_i.position = Vector2( randf_range(0,get_viewport_rect().size.x),randf_range(0,get_viewport_rect().size.y) )
	
	add_child(boid_i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
